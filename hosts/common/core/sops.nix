
{
  config,
  nix-secrets,
  ...
}: {
  sops = {
    defaultSopsFile = "${nix-secrets}/secrets/secrets.yaml";

    age = {
      sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
      keyFile = "/var/lib/sops-nix/key.txt";
      generateKey = true;
    };

    secrets = {
      openai_api_key = {
        owner = "addg";

      };
    };
  };

  programs.zsh.shellInit = ''
    export OPENAI_API_KEY=$(cat ${config.sops.secrets.openai_api_key.path})
  '';
}
