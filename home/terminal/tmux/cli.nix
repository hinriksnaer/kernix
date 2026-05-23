# Tmux CLI tools -- sessionizer for project-based session management.
# Packaged via writeShellApplication so it gets shellcheck, set -euo pipefail,
# and runtimeInputs automatically.
{pkgs, ...}: {
  home.packages = [
    (pkgs.writeShellApplication {
      name = "kernix-sessionizer";
      runtimeInputs = with pkgs; [fzf coreutils tmux];
      text = builtins.readFile ./sessionizer.sh;
    })
  ];
}
