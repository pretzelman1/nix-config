{}

# {
#   config,
#   configLib,
#   lib,
#   nix-secrets,
#   ...
# }: {
#   sops.defaultSopsFile = "${nix-secrets}/secrets/secrets.yaml";
#   sops.age = {
#     sshKeyPaths = ["${configLib.getHomeDirectory config.home.username}/.ssh/id_ed25519"];
#     keyFile = "${configLib.getHomeDirectory config.home.username}/.config/sops/age/key.txt";
#     generateKey = true;
#   };

#   sops.secrets = {
#     openai_api_key = {};
#     langchain_api_key = {};
#     tavily_api_key = {};
#   };

#   programs.zsh.initExtra = ''
#     export SOPS_AGE_KEY_FILE=~/.config/sops/age/keys.txt
#     # export OPENAI_API_KEY=$(cat ${config.sops.secrets.openai_api_key.path})
#     # export LANGCHAIN_API_KEY=$(cat ${config.sops.secrets.langchain_api_key.path})
#     # export TAVILY_API_KEY=$(cat ${config.sops.secrets.tavily_api_key.path})
#   '';
# }
