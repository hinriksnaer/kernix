# Patch opencode for non-NixOS hosts (Fedora + dnf install nix).
# Bun-compiled binaries trigger a glibc 2.42 ld.so assertion when loaded
# via Nix's dynamic linker. Rewrite the interpreter to the system linker
# (glibc 2.40), which is compatible (only GLIBC_2.34 symbols are needed).
# The if guard makes this a no-op on NixOS (no /lib64/ld-linux-x86-64.so.2).
# Remove this overlay once glibc fixes the assertion upstream.
final: prev: {
  opencode = let
    patched =
      final.runCommand "opencode-patched" {
        nativeBuildInputs = [final.patchelf];
      } ''
        mkdir -p $out/bin
        cp ${prev.opencode}/bin/.opencode-wrapped $out/bin/opencode
        chmod u+wx $out/bin/opencode
        if [ -f /lib64/ld-linux-x86-64.so.2 ]; then
          patchelf --set-interpreter /lib64/ld-linux-x86-64.so.2 $out/bin/opencode
        fi
      '';
  in
    final.writeShellScriptBin "opencode" ''
      export PATH="${prev.ripgrep}/bin''${PATH:+:$PATH}"
      exec ${patched}/bin/opencode "$@"
    '';
}
