# Terminal emulator abstraction.
# Defines config.kernix.terminal.* options, imports all backends
# unconditionally, and each backend activates via mkIf.
#
# To switch terminals: change `terminal` in settings.nix.
{lib, ...}: {
  imports = [
    ./ghostty.nix
    ./kitty.nix
  ];

  options.kernix.terminal = {
    command = lib.mkOption {
      type = lib.types.str;
      description = "Terminal executable name";
    };
    execFlag = lib.mkOption {
      type = lib.types.str;
      description = "Flag to execute a command inside the terminal";
    };
    windowClass = lib.mkOption {
      type = lib.types.str;
      description = "Window class for compositor rules";
    };
    themeHook = {
      source = lib.mkOption {
        type = lib.types.str;
        description = "Theme source filename in theme directories";
      };
      target = lib.mkOption {
        type = lib.types.str;
        description = "Symlink target path for theme file";
      };
      reload = lib.mkOption {
        type = lib.types.str;
        description = "Reload command (empty if terminal auto-reloads)";
      };
    };
  };
}
