{
  lib,
  name,
  inputs,
  config,
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
      nix-homebrew.darwinModules.nix-homebrew
      {
        nix-homebrew = {
          enable = true;
          enableRosetta = true;
          user = "${config.hostSpec.username}";
          autoMigrate = true;
        };
      }
      ../hosts/${name}
    ];
  }
