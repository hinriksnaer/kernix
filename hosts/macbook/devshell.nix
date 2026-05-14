# Helion development shell for macOS (MPS backend).
# Mirrors nixtorch's helion setup but targets Apple Silicon GPU.
{pkgs}:
pkgs.mkShell {
  name = "helion-mps";

  packages = with pkgs; [
    python3
    uv
    cmake
    ninja
    gnumake
    pkg-config
    git
  ];

  env = {
    HELION_REPO = "https://github.com/pytorch/helion.git";
    HELION_BRANCH = "main";
    HELION_TORCH_INDEX = "nightly/cpu";
    HELION_BACKENDS = "mps";
    PYTORCH_ENABLE_MPS_FALLBACK = "1";
  };

  shellHook = ''
    export HELION_WORKSPACE="''${HELION_WORKSPACE:-$HOME/workspace}"
    export PATH="$HOME/.local/bin:$PATH"

    # Activate shared venv if it exists
    if [ -f "$HELION_WORKSPACE/.venv/bin/activate" ]; then
      source "$HELION_WORKSPACE/.venv/bin/activate"
    fi
  '';
}
