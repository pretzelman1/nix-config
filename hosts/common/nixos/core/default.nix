{
  inputs,
  outputs,
  configLib,
  lib,
  ...
}: {
  imports = lib.flatten [
    (configLib.scanPaths ./.)
    inputs.sops-nix.nixosModules.sops
    inputs.home-manager.nixosModules.home-manager
  ];
}
