{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.services.autoTimezone;
in {
  options.services.autoTimezone = {
    enable = mkEnableOption "Automatically detect and set the system timezone via IP using tzupdate";

    package = mkOption {
      type = types.package;
      default = pkgs.tzupdate;
      description = "The tzupdate package to use.";
    };

    interval = mkOption {
      type = types.str;
      default = "24h";
      description = "How often to run tzupdate (e.g. '24h', '1h').";
    };

    onBootDelay = mkOption {
      type = types.str;
      default = "5min";
      description = "Delay after boot before the first run.";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [cfg.package pkgs.curl];

    systemd.services.auto-timezone = {
      description = "Automatically detect and set system timezone via IP";
      after = ["network-online.target"];
      wants = ["network-online.target"];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${cfg.package}/bin/tzupdate";
      };
    };

    systemd.timers.auto-timezone = {
      wantedBy = ["timers.target"];
      partOf = ["auto-timezone.service"];
      timerConfig = {
        OnBootSec = cfg.onBootDelay;
        OnUnitActiveSec = cfg.interval;
        Persistent = true;
      };
    };
  };
}
