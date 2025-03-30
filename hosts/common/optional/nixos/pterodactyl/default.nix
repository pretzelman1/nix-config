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
}
