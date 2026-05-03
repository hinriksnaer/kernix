# Power menu -- rofi-based shutdown/reboot/logout dialog.
{pkgs, ...}: {
  home.packages = [
    (pkgs.writeShellApplication {
      name = "power-menu";
      runtimeInputs = with pkgs; [rofi systemd];
      text = builtins.readFile ./scripts/power-menu.sh;
      excludeShellChecks = ["SC2029" "SC2016"];
    })
  ];
}
