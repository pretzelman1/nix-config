{
  pkgs ? import <nixpkgs> {},
  configLib,
}: rec {
  #################### Packages with external source ####################
  imports = configLib.scanPaths ./top-level;
}
