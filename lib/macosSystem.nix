{
  lib,
  name,
  inputs,
  configLib,
  configVars,
  system,
  specialArgs,
  ...
}: let
  inherit (inputs) nixpkgs-darwin home-manager nix-darwin nix-homebrew;
in
  nix-darwin.lib.darwinSystem {
    inherit system specialArgs;
    modules = [
      {home-manager.extraSpecialArgs = specialArgs;}
      ../hosts/${name}
    ];
  }
