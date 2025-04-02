{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.pterodactyl.panel;

  # Move reusable derivations into their own bindings
  php = pkgs.php.withExtensions ({
    enabled,
    all,
  }:
    with all; [
      bcmath
      curl
      gd
      mbstring
      mysqli
      tokenizer
      xml
      zip
      openssl
      pdo
      pdo_mysql
      posix
      simplexml
      session
      sodium
      fileinfo
      dom
      filter
    ]);

  composer = pkgs.php.packages.composer.override {inherit php;};

  userCreationScript = import ./user-setup.nix {inherit lib pkgs php cfg;};
  panelSetupScript = import ./panel-setup.nix {inherit pkgs php composer cfg;};
in
  lib.mkIf cfg.enable {
    users.users.${cfg.user} = {
      isSystemUser = true;
      group = cfg.group;
    };

    users.groups.${cfg.group} = {};

    services.mysql = {
      enable = true;
      package = pkgs.mariadb;
      ensureDatabases = [cfg.database.name];
      ensureUsers = [
        {
          name = cfg.database.user;
          ensurePermissions = {
            "${cfg.database.name}.*" = "ALL PRIVILEGES";
          };
        }
      ];
    };

    services.redis.servers."".enable = true;

    services.nginx = {
      enable = true;
      virtualHosts.${cfg.domain} = {
        root = "${cfg.dataDir}/public";
        enableACME = cfg.ssl;
        forceSSL = cfg.ssl;
        locations."/" = {
          index = "index.php";
          tryFiles = "$uri $uri/ /index.php?$query_string";
        };
        locations."~ \\.php$" = {
          extraConfig = ''
            include ${pkgs.nginx}/conf/fastcgi_params;
            fastcgi_pass unix:/run/phpfpm/pterodactyl.sock;
            fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
          '';
        };
      };
    };

    services.phpfpm.pools.pterodactyl = {
      user = cfg.user;
      group = cfg.group;
      phpPackage = php;
      settings = {
        listen = "/run/phpfpm/pterodactyl.sock";
        "listen.owner" = cfg.user;
        "listen.group" = config.services.nginx.group;
        "listen.mode" = "0660";
        pm = "dynamic";
        "pm.max_children" = 50;
        "pm.start_servers" = 5;
        "pm.min_spare_servers" = 2;
        "pm.max_spare_servers" = 10;
      };
    };

    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0755 ${cfg.user} ${cfg.group} -"
    ];

    systemd.services.setup-pterodactyl-db = {
      description = "Setup Pterodactyl MySQL Database and User";
      after = ["mysql.service"];
      wantedBy = ["multi-user.target"];
      serviceConfig.Type = "oneshot";
      script = ''
        set -e
        ${pkgs.mariadb}/bin/mysql <<EOF
        CREATE USER IF NOT EXISTS '${cfg.database.user}'@'${cfg.database.host}' IDENTIFIED VIA unix_socket;
        GRANT ALL PRIVILEGES ON ${cfg.database.name}.* TO '${cfg.database.user}'@'${cfg.database.host}';
        FLUSH PRIVILEGES;
        EOF
      '';
    };

    systemd.services.pterodactyl-panel-setup = {
      description = "Setup Pterodactyl Panel";
      after = ["network.target" "mysql.service" "setup-pterodactyl-db.service"];
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        Type = "oneshot";
        User = cfg.user;
        Group = cfg.group;
        WorkingDirectory = cfg.dataDir;
        ExecStart = panelSetupScript;
      };
    };

    systemd.services.pterodactyl-panel-user-setup = {
      description = "Create Pterodactyl Admin Users";
      wantedBy = ["multi-user.target"];
      after = ["pterodactyl-panel-setup.service"];
      serviceConfig = {
        Type = "oneshot";
        User = "root";
        WorkingDirectory = cfg.dataDir;
        ExecStart = userCreationScript;
      };
    };
  }
