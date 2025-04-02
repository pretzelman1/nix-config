{
  pkgs,
  config,
  nix-secrets,
  ...
}: {
  services.pterodactyl.wings = {
    enable = true;
    token_id_path = config.sops.secrets.pterodactylTokenId.path;
    token_path = config.sops.secrets.pterodactylToken.path;
    settings = {
      api = {
        ssl.enabled = false;
        port = 8983;
      };
      uuid = "e33f6160-0a3f-4f1c-9537-63253c8e14ed";
      system = {
        data = "/var/lib/pterodactyl/volumes";
      };
      remote = "http://${config.services.pterodactyl.panel.domain}";
    };
  };

  services.pterodactyl.panel = {
    enable = true;

    domain = "panel.local"; # or your actual domain
    ssl = false; # set to true if using ACME (Let's Encrypt)
    users = {
      primary = {
        email = config.hostSpec.email.user;
        username = config.hostSpec.username;
        firstName = config.hostSpec.username;
        lastName = "G";
        passwordFile = config.sops.secrets.pterodactylAdminPassword.path;
        isAdmin = true;
      };
    };
  };

  networking.hosts = {
    "127.0.0.1" = ["panel.local"];
  };

  sops.secrets = {
    pterodactylAdminPassword = {
      sopsFile = "${nix-secrets}/secrets/pterodactyl.yaml";
      mode = "0400";
      owner = "root";
    };
    pterodactylTokenId = {
      sopsFile = "${nix-secrets}/secrets/pterodactyl.yaml";
      mode = "0400";
      owner = config.services.pterodactyl.wings.user;
    };
    pterodactylToken = {
      sopsFile = "${nix-secrets}/secrets/pterodactyl.yaml";
      mode = "0400";
      owner = config.services.pterodactyl.wings.user;
    };
  };

  security.firewall.allowedTCPPorts = [80 443 8983 25565];
}
