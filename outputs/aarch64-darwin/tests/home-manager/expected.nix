{
  configVars,
  lib,
}: let
  username = configVars.username;
  hosts = [
    "fern"
  ];
in
  lib.genAttrs hosts (_: "/Users/${username}")
