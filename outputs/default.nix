{
  self,
  nixpkgs,
  pre-commit-hooks,
  home-manager,
  nix-darwin,
  nur-ryan4yin,
  nix-homebrew,
  nix-secrets,
  sops-nix,
  ...
} @ inputs: let
  inherit (inputs.nixpkgs) lib;
  inherit (self) outputs;
  configVars = import ../vars {inherit inputs lib;};
  pkgs = inputs.nixpkgs;
  configLib = import ../lib {inherit lib configVars pkgs;};

  # Add  custom lib, vars, nixpkgs instance, and all the inputs to specialArgs,
  # so that I can use them in all my nixos/home-manager/darwin modules.
  genSpecialArgs = system:
    inputs
    // {
      inherit configLib configVars;
    };

  # This is the args for all the haumea modules in this folder.
  args = {inherit inputs outputs lib configLib configVars genSpecialArgs;};
  specialArgs = {
    inherit
      inputs
      outputs
      configVars
      configLib
      nixpkgs
      nur-ryan4yin
      nix-secrets
      ;
  };

  # modules for each supported system
  nixosSystems = {
    # x86_64-linux = import ./x86_64-linux (args // {system = "x86_64-linux";});
    # aarch64-linux = import ./aarch64-linux (args // {system = "aarch64-linux";});
    # riscv64-linux = import ./riscv64-linux (args // {system = "riscv64-linux";});
  };
  darwinSystems = {
    #aarch64-darwin = import ./aarch64-darwin (args // {system = "aarch64-darwin";});
    # x86_64-darwin = import ./x86_64-darwin (args // {system = "x86_64-darwin";});
  };
  allSystems = nixosSystems // darwinSystems;
  allSystemNames = builtins.attrNames allSystems;
  nixosSystemValues = builtins.attrValues nixosSystems;
  darwinSystemValues = builtins.attrValues darwinSystems;
  allSystemValues = nixosSystemValues ++ darwinSystemValues;

  # Helper function to generate a set of attributes for each system
  forAllSystems = func: (nixpkgs.lib.genAttrs allSystemNames func);
in {
  # Add attribute sets into outputs, for debugging
  debugAttrs = {inherit nixosSystems darwinSystems allSystems allSystemNames;};

  homeManagerModules = import ../modules/home-manager;

  # NixOS Hosts
  nixosConfigurations =
    lib.attrsets.mergeAttrsList (map (it: it.nixosConfigurations or {}) nixosSystemValues);

  # macOS Hosts
  darwinConfigurations =
    lib.attrsets.mergeAttrsList (map (it: it.darwinConfigurations or {}) darwinSystemValues)
    // {
      fern = nix-darwin.lib.darwinSystem {
        inherit specialArgs;
        system = "aarch64-darwin";
        modules = [
          home-manager.darwinModules.home-manager
          {home-manager.extraSpecialArgs = specialArgs;}
          sops-nix.darwinModules.sops
          nix-homebrew.darwinModules.nix-homebrew
          {
            nix-homebrew = {
              enable = true;
              enableRosetta = true;
              user = "${configVars.username}";
            };
          }
          ../hosts/fern
        ];
      };
    };

  # Custom modifications/overrides to upstream packages.
  overlays = import ../overlays {inherit inputs outputs;};

  # Colmena - remote deployment via SSH
  colmena =
    {
      meta =
        (
          let
            system = "x86_64-linux";
          in {
            # colmena's default nixpkgs & specialArgs
            nixpkgs = import nixpkgs {inherit system;};
            specialArgs = genSpecialArgs system;
          }
        )
        // {
          # per-node nixpkgs & specialArgs
          nodeNixpkgs = lib.attrsets.mergeAttrsList (map (it: it.colmenaMeta.nodeNixpkgs or {}) nixosSystemValues);
          nodeSpecialArgs = lib.attrsets.mergeAttrsList (map (it: it.colmenaMeta.nodeSpecialArgs or {}) nixosSystemValues);
        };
    }
    // lib.attrsets.mergeAttrsList (map (it: it.colmena or {}) nixosSystemValues);

  # Packages
  packages = forAllSystems (
    system: allSystems.${system}.packages or {}
  );

  # Eval Tests for all NixOS & darwin systems.
  evalTests = lib.lists.all (it: it.evalTests == {}) allSystemValues;

  checks = forAllSystems (
    system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in
      import ./checks {inherit inputs system pkgs;}
  );

  # Development Shells
  devShells = forAllSystems (
    system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      default = pkgs.mkShell {
        packages = with pkgs; [
          bashInteractive
          gcc
          alejandra
          deadnix
          statix
          typos
        ];
        name = "dots";
        shellHook = ''
          ${self.checks.${system}.pre-commit-check.shellHook}
        '';
      };
    }
  );

  # Format the nix code in this flake
  formatter = forAllSystems (
    system: nixpkgs.legacyPackages.${system}.alejandra
  );
}
