{
  inputs,
  lib,
  name,
  system,
  specialArgs,
  configVars,
  ...
}: let
  inherit (inputs) nixpkgs home-manager nixos-generators;

  modules = [
    {home-manager.extraSpecialArgs = specialArgs;}
    ../hosts/${name}
  ];

  nixosSystem = nixpkgs.lib.nixosSystem {
    inherit system specialArgs modules;
  };
in {
  inherit nixosSystem modules system;
}
