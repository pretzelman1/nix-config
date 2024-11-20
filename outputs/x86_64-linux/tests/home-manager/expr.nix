# {
#   configVars,
#   lib,
#   outputs,
# }: let
#   username = configVars.username;
#   hosts = [
#     "ghost"
#   ];
# in
#   lib.genAttrs
#   hosts
#   (
#     name: outputs.nixosConfigurations.${name}.config.home-manager.users.${username}.home.homeDirectory
#   )
{}
