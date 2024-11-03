{
  lib,
  inputs,
  darwin-modules,
  home-modules ? [],
  configVars,
  system,
  genSpecialArgs,
  specialArgs ? (genSpecialArgs system),
  ...
}: let
  inherit (inputs) nixpkgs-darwin home-manager nix-darwin nix-homebrew;
in
  nix-darwin.lib.darwinSystem {
    inherit system specialArgs;
    modules =
      darwin-modules
      ++ [
        ({lib, ...}: {
          nixpkgs.pkgs = import nixpkgs-darwin {inherit system; config.allowUnfree = true;};
        })
      ]
      ++ (
        lib.optionals ((lib.lists.length home-modules) > 0)
        [
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

            home-manager.extraSpecialArgs = specialArgs;
            home-manager.users."${configVars.username}".imports = home-modules;
          }
        ]
      )
      ++ [
        # Add nix-homebrew module
        nix-homebrew.darwinModules.nix-homebrew {
          nix-homebrew = {
            enable = true;
            enableRosetta = true;
            user = "${configVars.username}";
          };
        }
      ];
  }
