{
  config,
  configLib,
  lib,
  nix-secrets,
  ...
}: {
  sops = {
    defaultSopsFile = "${nix-secrets}/secrets/secrets.yaml";
    age = {
      sshKeyPaths = ["${config.home.homeDirectory}/.ssh/id_ed25519"];
      keyFile = "${config.home.homeDirectory}/.config/sops-nix/age/keys.txt";
      generateKey = true;
    };
  };

  sops.secrets = {
    openai_api_key = {};
    langchain_api_key = {};
    tavily_api_key = {};
    aws_credentials = {
      format = "binary";
      sopsFile = "${nix-secrets}/secrets/shipperhq/aws-credentials.enc";
      path = "${config.home.homeDirectory}/.aws/credentials";
    };
  };

  programs.zsh.initExtra = ''
    export SOPS_AGE_KEY_FILE=~/.config/sops-nix/age/keys.txt
    export OPENAI_API_KEY=$(cat ${config.sops.secrets.openai_api_key.path})
    export LANGCHAIN_API_KEY=$(cat ${config.sops.secrets.langchain_api_key.path})
    export TAVILY_API_KEY=$(cat ${config.sops.secrets.tavily_api_key.path})
  '';

  # This is so I can use sops in the shell anywhere
  home.file.".sops.yaml" = {
    source = "${nix-secrets}/.sops.yaml";
  };
}
