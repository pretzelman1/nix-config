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
      nix-homebrew.darwinModules.nix-homebrew
      {
        nix-homebrew = {
          enable = true;
          enableRosetta = true;
          user = "${configVars.username}";
        };
      }
      ../hosts/${name}
    ];
  }
