{
  config,
  lib,
  nix-secrets,
  ...
}:
{
  sops = {
    defaultSopsFile = "${nix-secrets}/secrets/secrets.yaml";
    

    age = {
      sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
      keyFile = "/var/lib/sops-nix/key.txt";
      generateKey = true;
    };

    secrets = {
      openai_api_key = {
      };
    };
  };

  programs.zsh.initExtra = ''
    export OPENAI_API_KEY=$(cat ${config.sops.secrets.openai_api_key.path})
  '';
}
