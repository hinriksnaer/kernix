{pkgs, ...}: let
  # Custom fan control script using liquidctl to communicate with the
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
  fanControlScript = pkgs.writeShellScript "fan-control" ''
    set -euo pipefail

    INTERVAL=2
    SAMPLES=5

    # Temperature range (Celsius)
    MIN_TEMP=50
    MAX_TEMP=85

    # Exhaust fans (1-3): duty as percentage
    EXHAUST_MIN=15
    EXHAUST_MAX=90

    # Intake fans (4-6): duty as percentage
    INTAKE_MIN=20
    INTAKE_MAX=100

    LIQUIDCTL="${pkgs.liquidctl}/bin/liquidctl"

    # Find k10temp hwmon path (AMD CPU temperature sensor, PCI-based)
    find_k10temp() {
      for hwmon in /sys/class/hwmon/hwmon*; do
        if [ -f "$hwmon/name" ] && [ "$(cat "$hwmon/name")" = "k10temp" ]; then
          echo "$hwmon/temp1_input"
          return 0
        fi
      done
      return 1
    }

    TEMP_PATH=$(find_k10temp)
    if [ -z "$TEMP_PATH" ]; then
      echo "fan-control: k10temp sensor not found, exiting"
      exit 1
    fi
    echo "fan-control: using temperature sensor at $TEMP_PATH"

    # Initialize the Octo
    if ! timeout 10 $LIQUIDCTL --match octo initialize > /dev/null 2>&1; then
      echo "fan-control: failed to initialize Octo, exiting"
      exit 1
    fi
    echo "fan-control: Octo initialized"

    # Rolling average buffer
    declare -a temps
    idx=0

    # Linear interpolation: compute duty% for a given temperature
    calc_duty() {
      local temp=$1 min_duty=$2 max_duty=$3
      if [ "$temp" -le "$MIN_TEMP" ]; then
        echo "$min_duty"
      elif [ "$temp" -ge "$MAX_TEMP" ]; then
        echo "$max_duty"
      else
        echo $(( min_duty + (max_duty - min_duty) * (temp - MIN_TEMP) / (MAX_TEMP - MIN_TEMP) ))
      fi
    }

    # Set a fan channel's speed, with timeout to prevent hangs
    set_fan() {
      local fan=$1 duty=$2
      timeout 5 $LIQUIDCTL --match octo set fan"$fan" speed "$duty" > /dev/null 2>&1 || \
        echo "fan-control: warning: failed to set fan$fan to $duty%"
    }

    echo "fan-control: entering control loop (interval=''${INTERVAL}s, samples=$SAMPLES)"

    while true; do
      # Read CPU temperature (millidegrees Celsius)
      raw_temp=$(timeout 2 cat "$TEMP_PATH" 2>/dev/null || echo "")
      if [ -z "$raw_temp" ]; then
        echo "fan-control: warning: failed to read temperature, skipping cycle"
        sleep "$INTERVAL"
        continue
      fi
      temp=$((raw_temp / 1000))

      # Update rolling average
      temps[$idx]=$temp
      idx=$(( (idx + 1) % SAMPLES ))
      sum=0
      count=0
      for t in "''${temps[@]}"; do
        sum=$((sum + t))
        count=$((count + 1))
      done
      avg_temp=$((sum / count))

      # Calculate duty cycles
      exhaust_duty=$(calc_duty "$avg_temp" "$EXHAUST_MIN" "$EXHAUST_MAX")
      intake_duty=$(calc_duty "$avg_temp" "$INTAKE_MIN" "$INTAKE_MAX")

      # Set exhaust fans (1-3)
      set_fan 1 "$exhaust_duty"
      set_fan 2 "$exhaust_duty"
      set_fan 3 "$exhaust_duty"

      # Set intake fans (4-6)
      set_fan 4 "$intake_duty"
      set_fan 5 "$intake_duty"
      set_fan 6 "$intake_duty"

      sleep "$INTERVAL"
    done
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
