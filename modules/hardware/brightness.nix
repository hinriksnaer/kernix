# Brightness -- system-level only (video group membership).
# User tools (brightnessctl, brightness-control) are managed
# by Home Manager (home/modules/desktop/hardware-tools.nix).
{ config, ... }:

{
  users.users.${config.kernix.username}.extraGroups = [ "video" ];
}
