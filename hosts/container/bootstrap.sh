#!/usr/bin/env bash
# Bootstrap the kernix dev container on a remote podman host, from this
# machine. The local side needs nix (flakes); the remote side needs podman
# and, for GPU work, the NVIDIA driver. Nothing is installed on the remote
# host itself: the image is built here from this flake and streamed over
# ssh, and everything else happens inside the container.
#
# README.md in this directory explains what each step does and why the run
# flags look the way they do; this script is that document, executable. GPU
# device nodes, MIG capability nodes and the host library directory are
# probed on the remote rather than hard-coded, so the same invocation works
# on a MIG-partitioned H200 host (ibm-yugi) and a plain multi-GPU one.
#
# usage: bootstrap.sh <ssh-host> [options]
#
#   <ssh-host>     anything ssh accepts: a ~/.ssh/config alias, user@host
#   --name NAME    container name on the remote (default: kernix)
#   --helion PATH  local helion working tree to copy in; its devshell/ and
#                  .envrc are untracked by design, which is why this copies
#                  the tree instead of cloning (default: ~/workspace/helion)
#   --no-helion    skip the helion copy
#   --gpu N[,N..]  expose only /dev/nvidiaN (comma list) instead of every
#                  GPU on the host. N is the device-node minor number; on
#                  MIG hosts it need not match nvidia-smi's GPU index.
#   --recreate     replace an existing container of the same name
#   --no-verify    skip the final in-container checks; the helion one is the
#                  slow part (builds the devshell, downloads torch nightly)
set -euo pipefail

name=kernix
helion="$HOME/workspace/helion"
recreate=0
verify=1
host=""
gpus=""

usage() {
  sed -n '2,/^set -euo/p' "$0" | sed '$d' | sed 's/^# \{0,1\}//'
  exit "${1:-0}"
}

while [ $# -gt 0 ]; do
  case "$1" in
    --name) name="$2"; shift 2 ;;
    --helion) helion="$2"; shift 2 ;;
    --no-helion) helion=""; shift ;;
    --gpu) gpus="$2"; shift 2 ;;
    --recreate) recreate=1; shift ;;
    --no-verify) verify=0; shift ;;
    -h | --help) usage ;;
    -*)
      echo "unknown option: $1" >&2
      usage 1
      ;;
    *)
      if [ -n "$host" ]; then
        echo "unexpected argument: $1" >&2
        usage 1
      fi
      host="$1"
      shift
      ;;
  esac
done
if [ -z "$host" ]; then
  echo "ssh host required" >&2
  usage 1
fi

kernix_root="$(cd -- "$(dirname -- "$0")/../.." && pwd)"

remote() { ssh "$host" "$*"; }
# Quote a command once so it survives ssh's re-splitting and reaches the
# shell inside the container intact.
pod_sh() { ssh "$host" "podman exec -i $name sh -c $(printf '%q' "$1")"; }
pod_zsh() { ssh "$host" "podman exec -i -w /root $name zsh -lc $(printf '%q' "$1")"; }

# ── 1. Image: build here, stream to the remote ──
echo "==> building container image from $kernix_root"
out="$(mktemp -d)"
trap 'rm -rf "$out"' EXIT
nix build "$kernix_root#container-image" -o "$out/image"

echo "==> loading image on $host"
remote "podman load" <"$out/image"

# ── 2. Probe the remote for GPU devices and FHS library paths ──
# MIG hosts need /dev/nvidia-caps or the container sees the GPU but no
# compute device; Debian-family hosts keep their libraries in
# /usr/lib/x86_64-linux-gnu instead of /usr/lib64.
echo "==> probing GPU devices and library paths on $host"
gpu_nodes='/dev/nvidia[0-9]*'
if [ -n "$gpus" ]; then
  gpu_nodes=""
  for g in ${gpus//,/ }; do
    remote "test -e /dev/nvidia$g" || {
      echo "no /dev/nvidia$g on $host" >&2
      exit 1
    }
    gpu_nodes="$gpu_nodes /dev/nvidia$g"
  done
fi
runflags=$(remote '
  set --
  for d in /dev/nvidiactl /dev/nvidia-uvm '"$gpu_nodes"'; do
    [ -e "$d" ] && set -- "$@" --device "$d"
  done
  [ -d /dev/nvidia-caps ] && set -- "$@" -v /dev/nvidia-caps:/dev/nvidia-caps
  [ -d /lib64 ] && set -- "$@" -v /lib64:/lib64:ro
  if [ -d /usr/lib64 ]; then
    set -- "$@" -v /usr/lib64:/usr/lib64:ro
  elif [ -d /usr/lib/x86_64-linux-gnu ]; then
    set -- "$@" -v /usr/lib/x86_64-linux-gnu:/usr/lib/x86_64-linux-gnu:ro
  fi
  [ -x /usr/bin/nvidia-smi ] && set -- "$@" -v /usr/bin/nvidia-smi:/usr/bin/nvidia-smi:ro
  [ -d /proc/driver/nvidia ] && set -- "$@" -v /proc/driver/nvidia:/proc/driver/nvidia:ro
  echo "$@"')
case "$runflags" in
  *--device*) ;;
  *) echo "    no /dev/nvidia* on $host; continuing without GPU" >&2 ;;
esac

# ── 3. Container ──
if remote "podman container exists $name"; then
  if [ "$recreate" = 1 ]; then
    echo "==> removing existing container $name"
    remote "podman rm -f $name"
  else
    echo "container '$name' already exists on $host; pass --recreate to replace it" >&2
    exit 1
  fi
fi

echo "==> starting container $name"
remote "podman run -d --name $name --init --pull=never \
  --security-opt label=disable \
  $runflags \
  -e PATH=/root/.nix-profile/bin:/nix/var/nix/profiles/default/bin:/nix/var/nix/profiles/default/sbin:/usr/local/bin:/usr/bin:/bin \
  localhost/kernix:container sleep infinity"

echo "==> first-run shims (/usr/bin entry points, /etc/os-release)"
# readlink -f: resolve to the immutable store path, not ~/.nix-profile/bin.
# The profile apply below replaces ~/.nix-profile (dropBootstrapProfile),
# and the HM profile does not ship plain coreutils -- profile-relative
# links would dangle afterwards, breaking every #!/usr/bin/env script
# (tmux plugins, VS Code server probes).
pod_sh '
  for b in id cat ls mkdir rm chmod ln sed grep tar gzip which uname getent env bash sh; do
    p=$(command -v "$b" 2>/dev/null)
    [ -n "$p" ] && p=$(readlink -f "$p")
    [ -z "$p" ] && p=$(ls /nix/store/*/bin/"$b" 2>/dev/null | head -1)
    [ -n "$p" ] && ln -sf "$p" /usr/bin/"$b"
  done
  printf "NAME=NixOS\nID=nixos\n" >/etc/os-release'

# ── 4. Working trees + profile ──
# The working trees are copied rather than cloned: uncommitted kernix edits
# apply, and helion's devshell/ and .envrc only exist in the working tree.
echo "==> copying kernix working tree"
pod_sh 'mkdir -p /root/kernix /root/workspace'
tar -c --exclude=.git --exclude=result -C "$kernix_root" . |
  remote "podman exec -i $name tar -x -C /root/kernix"

echo "==> applying root@container profile (first run pulls several GB)"
remote "podman exec -w /root $name nix run /root/kernix#root@container"

if [ -n "$helion" ]; then
  if [ ! -d "$helion" ]; then
    echo "helion tree not found: $helion (use --helion PATH or --no-helion)" >&2
    exit 1
  fi
  echo "==> copying helion working tree ($helion)"
  tar -c --exclude=.venv --exclude=result -C "$(dirname "$helion")" "$(basename "$helion")" |
    remote "podman exec -i $name tar -x -C /root/workspace"
  pod_zsh "cd ~/workspace/$(basename "$helion") && direnv allow"
fi

# ── 5. Verify ──
if [ "$verify" = 1 ]; then
  echo "==> verify: nvidia-smi -L"
  remote "podman exec $name nvidia-smi -L" || true
  if [ -n "$helion" ]; then
    echo "==> verify: devshell + torch CUDA (first run builds the venv; ~10 min)"
    pod_zsh "cd ~/workspace/$(basename "$helion") && direnv exec . python -c \
      'import torch; print(torch.__version__, torch.cuda.is_available(), torch.cuda.get_device_name(0))'"
  fi
fi

echo "==> done. enter with: ssh -t $host podman exec -it -w /root $name zsh -l"
