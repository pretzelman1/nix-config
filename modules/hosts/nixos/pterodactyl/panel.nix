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
      ${pkgs.sd}/bin/sd '^DB_PASSWORD=.*' 'DB_PASSWORD=${cfg.database.password}' .env

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
      password = lib.mkOption {
        type = lib.types.str;
        description = "DB password";
      };
      host = lib.mkOption {
        type = lib.types.str;
        default = "localhost";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.${user} = {
      isNormalUser = true;
      group = group;
    };

    users.groups.${group} = {};

    services.mysql = {
      enable = true;
      package = pkgs.mariadb;

      ensureDatabases = ["panel"];
      ensureUsers = [
        {
          name = "pterodactyl";
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
        CREATE USER IF NOT EXISTS '${cfg.database.user}'@'${cfg.database.host}' IDENTIFIED BY '${cfg.database.password}';
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
  };
}
