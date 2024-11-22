# {
#   configVars,
#   lib,
# }: let
#   username = configVars.username;
#   hosts = [
#     "zephy"
#   ];
# in
#   lib.genAttrs hosts (_: "/home/${username}")
{}
