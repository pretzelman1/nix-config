{
  config,
  lib,
  isDarwin,
  ...
}:
with lib; let
  cfg = config.security.firewall;
  pfConf = import ./pf-generator.nix {inherit cfg lib;};
in {
  options.security.firewall = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable the cross-platform firewall.";
    };

    interfaces = mkOption {
      type = types.listOf types.str;
      default = ["en0" "en1"]; # Default to common macOS interfaces
      description = "List of network interfaces to apply firewall rules to.";
    };

    allowedInboundTCPPorts = mkOption {
      type = types.listOf types.port;
      default = [];
      description = "Allowed inbound TCP ports.";
    };

    allowedInboundUDPPorts = mkOption {
      type = types.listOf types.port;
      default = [];
      description = "Allowed inbound UDP ports.";
    };

    allowedOutboundTCPPorts = mkOption {
      type = types.listOf types.port;
      default = [];
      description = "Allowed outbound TCP ports.";
    };

    allowedOutboundUDPPorts = mkOption {
      type = types.listOf types.port;
      default = [];
      description = "Allowed outbound UDP ports.";
    };

    allowICMP = mkOption {
      type = types.bool;
      default = true;
      description = "Allow ICMP (e.g., ping).";
    };

    allowFromIPs = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "List of source IPs allowed for inbound rules.";
    };

    denyOutboundIPs = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "List of IPs to block for outbound connections.";
    };

    blockAllInbound = mkOption {
      type = types.bool;
      default = true;
      description = "Block all inbound traffic by default.";
    };

    blockAllOutbound = mkOption {
      type = types.bool;
      default = false;
      description = "Block all outbound traffic by default.";
    };
  };

  config = mkIf cfg.enable (
    mkMerge (
      lib.optional isDarwin {
        environment.etc."pf.conf".text = pfConf;

        launchd.daemons.pf = {
          serviceConfig = {
            Label = "com.nix.pf";
            ProgramArguments = ["/sbin/pfctl" "-f" "/etc/pf.conf" "-e"];
            RunAtLoad = true;
            KeepAlive = true;
            ThrottleInterval = 30;
            StandardErrorPath = "/var/log/pf.log";
            StandardOutPath = "/var/log/pf.log";
            ProcessType = "Interactive";
          };
        };

        system.activationScripts.pfctlFirewall = lib.stringAfter ["etc"] ''
          echo "→ Configuring macOS firewall..."

          /sbin/pfctl -d 2>/dev/null || true

          if /sbin/pfctl -f /etc/pf.conf -e; then
            echo "✓ Firewall rules loaded successfully"
            echo "Current rules:"
            /sbin/pfctl -s rules
          else
            echo "⚠ Failed to load firewall rules"
            echo "Current status:"
            /sbin/pfctl -s info
            exit 1
          fi
        '';
      }
      ++ lib.optional (!isDarwin) {
        networking.firewall = {
          enable = true;
          allowPing = cfg.allowICMP;
          allowedTCPPorts = cfg.allowedInboundTCPPorts ++ cfg.allowedOutboundTCPPorts;
          allowedUDPPorts = cfg.allowedInboundUDPPorts ++ cfg.allowedOutboundUDPPorts;
          extraCommands = lib.concatStringsSep "\n" (
            lib.optional cfg.blockAllInbound "iptables -P INPUT DROP"
            ++ lib.optional cfg.blockAllOutbound "iptables -P OUTPUT DROP"
            ++ map (ip: "iptables -A OUTPUT -d ${ip} -j DROP") cfg.denyOutboundIPs
          );
        };
      }
    )
  );
}
