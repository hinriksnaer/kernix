# Helion MPS backend development shell.
# For developing Metal/MPS backend support in Helion on Apple Silicon.
# Metal compiler (xcrun metal) and frameworks come from Xcode CLT.
{pkgs}: let
  helion-setup = pkgs.writeShellApplication {
    name = "helion-setup";
    runtimeInputs = with pkgs; [git uv python3];
    text = builtins.readFile ./helion-setup.sh;
    excludeShellChecks = ["SC1091"];
  };
in
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
      helion-setup

      # Metal shader tooling (llvm for IR generation/analysis)
      llvmPackages.llvm
      llvmPackages.clang
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

      # Expose Xcode CLT Metal toolchain (xcrun metal, metallib, etc.)
      if xcode-select -p &>/dev/null; then
        export SDKROOT="$(xcrun --show-sdk-path)"
      fi

      # Activate shared venv if it exists
      if [ -f "$HELION_WORKSPACE/.venv/bin/activate" ]; then
        source "$HELION_WORKSPACE/.venv/bin/activate"
      fi
    '';
  }
