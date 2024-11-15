{
  configVars,
  lib,
}: let
  username = configVars.username;
  hosts = [
    "harmonica"
  ];
in
  lib.genAttrs hosts (_: "/Users/${username}")
