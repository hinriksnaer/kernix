# Kernix theme engine -- consumes the kernix-theme flake.
#
# Apps opt into theming by adding their app name to `kernix.theme.hooks`:
#
#   kernix.theme.hooks = [ "btop" "neovim" ];
#
# or by declaring a full app under `kernix.theme.apps.<name>` (used by
# third-party flakes). Enabled apps are compiled into
# ~/.config/kernix/apps.sh and processed by kernix-theme-apply at runtime;
# adapters and CLI tools come from each app's `provide` plus the engine core.
{
  host,
  kernix-theme,
  ...
}: {
  imports = [kernix-theme.homeManagerModules.theme];

  config.kernix.theme.selected = host.defaultTheme;
}
