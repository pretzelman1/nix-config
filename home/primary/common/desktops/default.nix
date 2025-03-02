{
  config,
  lib,
  pkgs,
  inputs,
  hostSpec,
  ...
}: let
  platform =
    if hostSpec.isDarwin
    then "darwin"
    else "nixos";
in {
  imports = lib.flatten [
    (lib.custom.scanPaths ./.)
    inputs.spicetify-nix.homeManagerModules.spicetify
    ./${platform}
  ];
}
