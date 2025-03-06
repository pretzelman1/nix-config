{
  config,
  lib,
  pkgs,
  nix-secrets,
  ...
}: {
  home.packages = with pkgs; [
    cachix
  ];

  sops.secrets = {
    cachix_auth_token = {};
  };

  programs.zsh.initExtra = ''
    export CACHIX_AUTH_TOKEN=$(cat ${config.sops.secrets.cachix_auth_token.path})
  '';
}
