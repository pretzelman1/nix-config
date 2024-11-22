# {
#   configVars,
#   lib,
#   outputs,
# }: let
#   username = configVars.username;
#   hosts = [
#     "zephy"
#   ];
# in
#   lib.genAttrs
#   hosts
#   (
#     name: outputs.nixosConfigurations.${name}.config.home-manager.users.${username}.home.homeDirectory
#   )
{}
