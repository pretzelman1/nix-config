{lib, ...}:
with lib; {
  options.services.pterodactyl.panel = {
    enable = mkEnableOption "Enable Pterodactyl Panel";

    user = mkOption {
      type = types.str;
      default = "pterodactyl";
      description = "User under which the panel will run.";
    };

    group = mkOption {
      type = types.str;
      default = "pterodactyl";
      description = "Group under which the panel will run.";
    };

    domain = mkOption {
      type = types.str;
      description = "Domain name to serve the panel.";
    };

    dataDir = mkOption {
      type = types.path;
      default = "/var/www/pterodactyl";
      description = "Directory where the panel files are stored.";
    };

    ssl = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to enable SSL/ACME.";
    };

    database = {
      name = mkOption {
        type = types.str;
        default = "panel";
      };
      user = mkOption {
        type = types.str;
        default = "pterodactyl";
      };
      host = mkOption {
        type = types.str;
        default = "localhost";
      };
    };

    users = mkOption {
      type = types.attrsOf (types.submodule {
        options = {
          email = mkOption {
            type = types.str;
            description = "Email address for this user.";
          };
          username = mkOption {
            type = types.str;
            description = "Username for this user.";
          };
          firstName = mkOption {
            type = types.str;
            description = "First name of the user.";
          };
          lastName = mkOption {
            type = types.str;
            description = "Last name of the user.";
          };
          passwordFile = mkOption {
            type = types.path;
            description = "Path to file containing this user's password.";
          };
          isAdmin = mkOption {
            type = types.bool;
            default = false;
            description = "Whether this user should be an admin.";
          };
        };
      });
      default = {};
      description = "Map of panel users to create.";
    };
  };
}
