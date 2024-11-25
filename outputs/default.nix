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
  configLib = import ../lib {inherit lib configVars;};

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

  # This is the args for all the haumea modules in this folder.
  args = {inherit inputs outputs lib configLib configVars specialArgs;};

  # modules for each supported system
  nixosSystems = {
    x86_64-linux = import ./x86_64-linux (args // {system = "x86_64-linux";});
    # aarch64-linux = import ./aarch64-linux (args // {system = "aarch64-linux";});
    # riscv64-linux = import ./riscv64-linux (args // {system = "riscv64-linux";});
  };
  darwinSystems = {
    aarch64-darwin = import ./aarch64-darwin (args // {system = "aarch64-darwin";});
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
    lib.attrsets.mergeAttrsList (map (it: it.darwinConfigurations or {}) darwinSystemValues);

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
            specialArgs = specialArgs;
          }
        )
        // {
          # per-node nixpkgs & specialArgs
          nodeNixpkgs = lib.attrsets.mergeAttrsList (map (it: it.colmenaMeta.nodeNixpkgs or {}) nixosSystemValues);
          nodeSpecialArgs = lib.attrsets.mergeAttrsList (map (it: it.colmenaMeta.nodeSpecialArgs or {}) nixosSystemValues);
        };
    }
    // lib.attrsets.mergeAttrsList (map (it: it.colmena or {}) nixosSystemValues);

  # Eval Tests for all NixOS & darwin systems.
  evalTests = lib.lists.all (it: it.evalTests == {}) allSystemValues;

  # Packages, checks, devShells and formatter for all systems
  packages = forAllSystems (system: let
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    packages = allSystems.${system}.packages or {};
    checks = import ../checks {inherit inputs system pkgs;};
    devShells = import ./devshell.nix {inherit self nixpkgs;} system;
    formatter = pkgs.alejandra;
  });

  checks = forAllSystems (system: packages.${system}.checks);
  devShells = forAllSystems (system: packages.${system}.devShells);
  formatter = forAllSystems (system: packages.${system}.formatter);
}
