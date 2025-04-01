{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.services.pterodactyl.panel;
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
  user = cfg.user;
  group = cfg.group;
  dataDir = cfg.dataDir;
  nginxUser = config.services.nginx.user;
  userCreationScript = pkgs.writeShellScript "pterodactyl-user-setup" ''
    set -e
    cd ${cfg.dataDir}
    echo "[+] Creating Pterodactyl users..."

    ${lib.concatStringsSep "\n" (
      lib.mapAttrsToList (name: userCfg: ''
        echo "[+] Creating ${userCfg.username}..."

        PASSWORD=$(cat ${userCfg.passwordFile} | tr -d '\r\n')

        env PASSWORD="$PASSWORD" ${pkgs.su}/bin/su --preserve-environment -s ${pkgs.bash}/bin/bash - ${cfg.user} -c '
          set +o history
          cd ${cfg.dataDir}
          echo "[DEBUG] Password inside su: [$PASSWORD]"
          ${php}/bin/php artisan p:user:make \
            --email="${userCfg.email}" \
            --username="${userCfg.username}" \
            --name-first="${userCfg.firstName}" \
            --name-last="${userCfg.lastName}" \
            --password="$PASSWORD" \
            --admin=${
          if userCfg.isAdmin
          then "1"
          else "0"
        } \
            --no-interaction
        ' || echo "[!] Skipping — user '${userCfg.username}' may already exist."

        unset PASSWORD
      '')
      cfg.users
    )}
  '';

  panelSetupScript = pkgs.writeShellScript "pterodactyl-panel-setup" ''
    set -e
    cd ${dataDir}

    if [ ! -f artisan ]; then
      echo "[+] Downloading Pterodactyl Panel..."
      ${pkgs.curl}/bin/curl -Lo panel.tar.gz https://github.com/pterodactyl/panel/releases/latest/download/panel.tar.gz
      ${pkgs.busybox}/bin/tar -xzvf panel.tar.gz
      rm panel.tar.gz

      echo "[+] Installing dependencies..."
      cp .env.example .env

      echo "[+] Configuring environment..."
      ${pkgs.sd}/bin/sd '^DB_HOST=.*' 'DB_HOST=${cfg.database.host}' .env
      ${pkgs.sd}/bin/sd '^DB_DATABASE=.*' 'DB_DATABASE=${cfg.database.name}' .env
      ${pkgs.sd}/bin/sd '^DB_USERNAME=.*' 'DB_USERNAME=${cfg.database.user}' .env
      ${pkgs.sd}/bin/sd '^DB_PASSWORD=.*' 'DB_PASSWORD=' .env

      ${composer}/bin/composer install --no-dev --optimize-autoloader
      ${php}/bin/php artisan key:generate --force
      ${php}/bin/php artisan migrate --seed --force

      chown -R ${user}:${group} .
    else
      echo "[=] Panel already installed, skipping setup."
    fi
  '';
in {
  options.services.pterodactyl.panel = {
    enable = lib.mkEnableOption "Enable Pterodactyl Panel";

    user = lib.mkOption {
      type = lib.types.str;
      default = "pterodactyl";
      description = "User under which the panel will run.";
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = "pterodactyl";
      description = "Group under which the panel will run.";
    };

    domain = lib.mkOption {
      type = lib.types.str;
      description = "Domain name to serve the panel.";
    };

    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/www/pterodactyl";
      description = "Directory where the panel files are stored.";
    };

    ssl = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to enable SSL/ACME.";
    };

    database = {
      name = lib.mkOption {
        type = lib.types.str;
        default = "panel";
      };
      user = lib.mkOption {
        type = lib.types.str;
        default = "pterodactyl";
      };
      host = lib.mkOption {
        type = lib.types.str;
        default = "localhost";
      };
    };

    users = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          email = lib.mkOption {
            type = lib.types.str;
            description = "Email address for this user.";
          };
          username = lib.mkOption {
            type = lib.types.str;
            description = "Username for this user.";
          };
          firstName = lib.mkOption {
            type = lib.types.str;
            description = "First name of the user.";
          };
          lastName = lib.mkOption {
            type = lib.types.str;
            description = "Last name of the user.";
          };
          passwordFile = lib.mkOption {
            type = lib.types.path;
            description = "Path to file containing this user's password.";
          };
          isAdmin = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Whether this user should be an admin.";
          };
        };
      });
      default = {};
      description = "Map of panel users to create.";
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.${user} = {
      isSystemUser = true;
      group = group;
    };

    users.groups.${group} = {};

    services.mysql = {
      enable = true;
      package = pkgs.mariadb;

      ensureDatabases = ["panel"];
      ensureUsers = [
        {
          name = user;
          ensurePermissions = {
            "panel.*" = "ALL PRIVILEGES";
          };
        }
      ];
    };

    services.redis.servers."".enable = true;

    services.nginx.enable = true;
    services.nginx.virtualHosts.${cfg.domain} = {
      root = "${dataDir}/public";
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

    services.phpfpm.pools.pterodactyl = {
      user = user;
      group = group;
      phpPackage = php;
      settings = {
        "listen" = "/run/phpfpm/pterodactyl.sock";
        "listen.owner" = user;
        "listen.group" = config.services.nginx.group;
        "listen.mode" = "0660";
        "user" = user;
        "group" = group;
        "pm" = "dynamic";
        "pm.max_children" = 50;
        "pm.start_servers" = 5;
        "pm.min_spare_servers" = 2;
        "pm.max_spare_servers" = 10;
      };
    };

    systemd.tmpfiles.rules = [
      "d ${dataDir} 0755 ${user} ${group} -"
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
        User = user;
        Group = group;
        WorkingDirectory = dataDir;
        ExecStart = "${panelSetupScript}";
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
        ExecStart = "${userCreationScript}";
      };
    };
  };
}
