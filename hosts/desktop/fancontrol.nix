# Custom fan control using liquidctl to communicate with the
# Aquacomputer Octo over USB in userspace, avoiding the D-state hangs
# caused by the aquacomputer_d5next kernel driver's blocking sysfs reads.
#
# Channel mapping (Aquacomputer Octo):
#   1 = Top exhaust (rear)      3 = Rear exhaust
#   2 = Top exhaust (front)     4 = Front intake (bottom)
#   5 = Front intake (top)      6 = Front intake (middle)
#
# Fan curves (quiet profile, AVERAGE=5 for smoothing):
#   Exhaust (1-3): <50C -> 15% | 67.5C -> 50% | 85C -> 90%
#   Intake  (4-6): <50C -> 20% | 67.5C -> 55% | 85C -> 100%
#   Intake runs higher than exhaust for positive pressure
{pkgs, ...}: let
  fanControlScript = pkgs.writeShellScript "fan-control" ''
    export LIQUIDCTL="${pkgs.liquidctl}/bin/liquidctl"
    ${builtins.readFile ./scripts/fan-control.sh}
  '';
in {
  # liquidctl for CLI use and udev rules for USB access
  environment.systemPackages = [pkgs.liquidctl];
  services.udev.packages = [pkgs.liquidctl];

  # Fan control service using liquidctl (replaces lm_sensors fancontrol)
  systemd.services.fan-control = {
    description = "Temperature-based fan control via liquidctl (Aquacomputer Octo)";
    wantedBy = ["multi-user.target"];
    after = ["systemd-udev-settle.service"];
    serviceConfig = {
      Restart = "on-failure";
      RestartSec = "5s";
      ExecStart = "${fanControlScript}";
    };
  };

  # Restart fan control after resume from sleep
  powerManagement.resumeCommands = ''
    systemctl restart fan-control.service
  '';
}
