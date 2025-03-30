{pkgs, ...}: {
  services.pterodactyl.wings = {
    enable = true;
    settings = {
      token_id = "dev-token-id";
      token = "super-secret";

      api = {
        ssl.enabled = false;
      };
    };
  };

  services.pterodactyl.panel = {
    enable = true;

    domain = "panel.local"; # or your actual domain
    ssl = false; # set to true if using ACME (Let's Encrypt)
    database.password = "hello";
  };

  security.firewall.allowedInboundTCPPorts = [80 443];
}
