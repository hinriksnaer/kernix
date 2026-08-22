# CLI tools -- shared across all profiles.
# HM handles shell integration (init, keybindings) automatically.
{
  pkgs,
  lib,
  settings,
  ...
}: {
  programs.starship = {
    enable = true;
    settings = {
      # Clean prompt -- hide verbose SSH hostname
      hostname.disabled = true;
      username.disabled = true;
      character = {
        success_symbol = "[❯](bold #aad94c)";
        error_symbol = "[❯](bold red)";
        vimcmd_symbol = "[❮](bold #f07178)";
      };
    };
  };

  programs.fzf = {
    enable = true;
    defaultCommand = "fd --type f --hidden --follow --exclude .git";
    defaultOptions = ["--height 40%" "--border"];
  };

  programs.zoxide.enable = true;

  programs.bat = {
    enable = true;
    config.pager = "less -FR";
  };

  programs.lsd.enable = true;

  programs.ripgrep.enable = true;
  programs.fd.enable = true;

  home.packages = [pkgs.glow];

  # Terminal emulator terminfo for SSH sessions (Linux only --
  # macOS terminal emulators ship their own terminfo).
  home.file.".terminfo" = lib.mkIf pkgs.stdenv.isLinux {
    source = "${pkgs.ghostty.terminfo}/share/terminfo";
  };

  # Man pager via bat
  home.sessionVariables = {
    MANPAGER = "sh -c 'col -bx | bat -l man -p'";
    MANROFFOPT = "-c";
  };
}
