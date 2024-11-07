
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

#   sops.secrets.openai_api_key = {
#     path = "${configLib.getHomeDirectory config.home.username}/.config/openai_api_key";
#   };

#   programs.zsh.initExtra = ''
#     export OPENAI_API_KEY=$(cat ${config.sops.secrets.openai_api_key.path})
#   '';
# }
