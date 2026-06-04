# Power management -- laptop only.
# TLP (CPU scaling, USB autosuspend, PCIe ASPM, WiFi powersave, charge thresholds),
# thermald (Intel thermal management), UPower (critical-battery actions),
# logind lid-switch behavior, and hibernate support.
{...}: {
  # ── Base power management (suspend-to-RAM, etc.) ──
  powerManagement.enable = true;

  # ── Intel thermal daemon ──
  # Proactively manages thermals via DPTF adaptive tables instead of
  # waiting for hard throttle limits.
  # ignoreCpuidCheck required for Meteor Lake (family 6, model 170).
  services.thermald = {
    enable = true;
    ignoreCpuidCheck = true;
  };

  # ── TLP ──
  # Comprehensive power tuning: CPU governor, energy policy, USB autosuspend,
  # PCIe ASPM, SATA link power, WiFi powersave, and charge thresholds.
  # Conflicts with auto-cpufreq -- do not enable both.
  services.tlp = {
    enable = true;
    settings = {
      # CPU governor: performance on AC, powersave on battery
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

      # Energy-performance preference (Intel HWP)
      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";

      # CPU performance limits on battery (percentage of max turbo)
      CPU_MIN_PERF_ON_AC = 0;
      CPU_MAX_PERF_ON_AC = 100;
      CPU_MIN_PERF_ON_BAT = 0;
      CPU_MAX_PERF_ON_BAT = 20;

      # Disable turbo boost on battery to reduce heat and power draw
      CPU_BOOST_ON_AC = 1;
      CPU_BOOST_ON_BAT = 0;

      # WiFi powersave: off on AC for stability, on for battery
      WIFI_PWR_ON_AC = "off";
      WIFI_PWR_ON_BAT = "on";

      # Battery charge thresholds (preserves long-term battery health).
      # Only effective if the laptop firmware supports it (most ThinkPads,
      # some ASUS/Huawei/Samsung/LG). Harmless no-op otherwise.
      START_CHARGE_THRESH_BAT0 = 40;
      STOP_CHARGE_THRESH_BAT0 = 80;
    };
  };

  # ── UPower ──
  # Battery monitoring with automatic critical-battery action.
  services.upower = {
    enable = true;
    # Percentage-based policy (more reliable than time-based)
    percentageLow = 20;
    percentageCritical = 5;
    percentageAction = 2;
    criticalPowerAction = "HybridSleep";
  };

  # ── Logind ──
  # Lid switch and power key behavior.
  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandleLidSwitchExternalPower = "lock";
    HandleLidSwitchDocked = "ignore";
    HandlePowerKey = "suspend";
    IdleAction = "suspend";
    IdleActionSec = "30min";
  };

  # ── Hibernate support ──
  # The swap partition already exists in hardware-configuration.nix.
  # resumeDevice enables the kernel to resume from hibernation.
  boot.resumeDevice = "/dev/disk/by-uuid/5436d935-9f0c-42fb-889a-933271d8ff04";

  # Suspend-then-hibernate: if left suspended for 1h, hibernate to
  # avoid slow battery drain while asleep.
  systemd.sleep.settings.Sleep = {
    HibernateDelaySec = "1h";
  };
}
