{
  configVars,
  lib,
}: let
  username = configVars.username;
  hosts = [
    "ghost"
  ];
in
  lib.genAttrs hosts (_: "/Users/${username}")
