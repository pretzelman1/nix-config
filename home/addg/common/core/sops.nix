{
  config,
  configLib,
  lib,
  nix-secrets,
  ...
}: {
  sops.defaultSopsFile = "${nix-secrets}/secrets/secrets.yaml";
  sops.age = {
    sshKeyPaths = ["${configLib.getHomeDirectory config.home.username}/.ssh/id_ed25519"];
    keyFile = "${configLib.getHomeDirectory config.home.username}/.config/sops/age/key.txt";
    generateKey = true;
  };

  sops.secrets = {
  };

  programs.zsh.initExtra = ''
    export SOPS_AGE_KEY_FILE=~/.config/sops/age/key.txt
  '';
}
