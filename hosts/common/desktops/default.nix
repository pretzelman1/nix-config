{
  config,
  lib,
  pkgs,
  inputs,
  isDarwin,
  ...
}: let
  platform =
    if isDarwin
    then "darwin"
    else "nixos";
  desktops = config.desktops;
in {
  imports = lib.flatten [
    # (lib.custom.scanPaths ./.)
    ./${platform}
    # ./${platform}/${desktops.appearance}
  ];
}
