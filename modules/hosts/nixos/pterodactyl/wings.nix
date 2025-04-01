{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.services.pterodactyl.wings;
  yamlType = (pkgs.formats.yaml {}).type;

  configFile = (pkgs.formats.yaml {}).generate "wings.yaml" cfg.settings;
in {
  options = {
    services.pterodactyl.wings = {
      enable = lib.mkEnableOption "Pterodactyl Wings";
      user = lib.mkOption {
        default = "pterodactyl";
        type = lib.types.str;
      };
      group = lib.mkOption {
        default = "pterodactyl";
        type = lib.types.str;
      };
      package = lib.mkOption {
        default = pkgs.nur.repos.xddxdd.pterodactyl-wings;
        defaultText = lib.literalExpression "pkgs.nur.repos.xddxdd.pterodactyl-wings";
        type = lib.types.package;
      };
      openFirewall = lib.mkOption {
        default = false;
        type = lib.types.bool;
      };
      allocatedTCPPorts = lib.mkOption {
        default = [];
        type = lib.types.listOf lib.types.port;
      };
      allocatedUDPPorts = lib.mkOption {
        default = [];
        type = lib.types.listOf lib.types.port;
      };

      extraConfigFile = lib.mkOption {
        default = null;
        type = lib.types.nullOr lib.types.path;
      };

      token_id_path = lib.mkOption {
        type = lib.types.path;
        description = "Path to SOPS-managed token ID file";
      };
      token_path = lib.mkOption {
        type = lib.types.path;
        description = "Path to SOPS-managed token file";
      };

      settings = lib.mkOption {
        default = {};
        type = lib.types.nullOr (lib.types.submodule {
          freeformType = yamlType;
          options = {
            api = lib.mkOption {
              default = {};
              type = lib.types.nullOr (lib.types.submodule {
                freeformType = yamlType;
                options = {
                  host = lib.mkOption {
                    type = lib.types.str;
                    default = "0.0.0.0";
                  };
                  port = lib.mkOption {
                    type = lib.types.port;
                    default = 443;
                  };
                  ssl = lib.mkOption {
                    default = {};
                    type = lib.types.nullOr (lib.types.submodule {
                      freeformType = yamlType;
                      options = {
                        enabled = lib.mkOption {
                          default = false;
                          type = lib.types.bool;
                        };
                        cert = lib.mkOption {
                          default = null;
                          type = lib.types.nullOr lib.types.str;
                        };
                        key = lib.mkOption {
                          default = null;
                          type = lib.types.nullOr lib.types.str;
                        };
                      };
                    });
                  };
                };
              });
            };
            system = lib.mkOption {
              default = {};
              type = lib.types.nullOr (lib.types.submodule {
                freeformType = yamlType;
                options = {
                  root_directory = lib.mkOption {
                    default = "/var/lib/pterodactyl";
                    type = lib.types.str;
                  };
                  username = lib.mkOption {
                    default = cfg.user;
                    type = lib.types.str;
                  };
                  sftp = lib.mkOption {
                    default = {};
                    type = lib.types.nullOr (lib.types.submodule {
                      freeformType = yamlType;
                      options = {
                        bind_address = lib.mkOption {
                          default = "0.0.0.0";
                          type = lib.types.str;
                        };
                        bind_port = lib.mkOption {
                          default = 2022;
                          type = lib.types.port;
                        };
                      };
                    });
                  };
                };
              });
            };
            ignore_panel_config_updates = lib.mkOption {
              default = true;
              type = lib.types.bool;
            };
          };
        });
      };
    };
  };

  config = lib.mkIf (cfg.enable) {
    virtualisation.docker.enable = true;
    users.groups."${cfg.group}".name = cfg.group;
    users.users.pterodactyl = {
      isSystemUser = true;
      group = cfg.group;
      extraGroups = ["docker"];
    };
    networking.firewall = lib.mkIf (cfg.openFirewall) {
      allowedTCPPorts = [cfg.settings.api.port cfg.settings.system.sftp.bind_port] ++ cfg.allocatedTCPPorts;
      allowedUDPPorts = cfg.allocatedUDPPorts;
    };
    systemd.tmpfiles.rules = [
      "d ${cfg.settings.system.root_directory} 0750 ${cfg.user} ${cfg.group} -"
      "d /var/log/pterodactyl 0750 ${cfg.user} ${cfg.group} -"
    ];
    systemd.services = {
      "wings" = {
        after = ["network.target"];
        requires = ["docker.service"];
        wantedBy = ["multi-user.target"];
        startLimitBurst = 30;
        startLimitIntervalSec = 180;
        preStart = ''
          echo "[wings-preStart] Reading token files..." >&2
          export TOKEN_ID=$(cat ${cfg.token_id_path})
          export TOKEN=$(cat ${cfg.token_path})
          echo "[wings-preStart] TOKEN_ID: $TOKEN_ID" >&2
          echo "[wings-preStart] TOKEN: [REDACTED]" >&2

          echo "[wings-preStart] Merging config files with yq-go..." >&2
          ${pkgs.yq-go}/bin/yq ea '. as $item ireduce ({}; . * $item )' \
            ${configFile} ${lib.optionalString (cfg.extraConfigFile != null) cfg.extraConfigFile} \
            > /tmp/wings-merged.yaml

          echo "[wings-preStart] Injecting token values..." >&2
          ${pkgs.yq-go}/bin/yq \
            '.token_id = strenv(TOKEN_ID) | .token = strenv(TOKEN)' \
            /tmp/wings-merged.yaml > ${cfg.settings.system.root_directory}/wings.yaml

          echo "[wings-preStart] Config written to ${cfg.settings.system.root_directory}/wings.yaml" >&2
        '';

        serviceConfig = {
          User = cfg.user;
          Group = cfg.group;
          LimitNOFILE = 4096;
          PIDFile = "/run/wings/daemon.pid";
          ExecStart = "${cfg.package}/bin/wings --config \"${cfg.settings.system.root_directory}/wings.yaml\"";
          Restart = "on-failure";
          RestartSec = "5s";
        };
      };
    };
  };
}
