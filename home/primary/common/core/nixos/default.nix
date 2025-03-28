{
  lib,
  pkgs,
  inputs,
  system,
  ...
}: {
  imports = lib.custom.scanPaths ./.;

  home.packages = with pkgs; [
  ];
}
