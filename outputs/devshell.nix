{
  self,
  nixpkgs,
  ...
}: system: let
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
      colmena
    ];
    name = "dots";
    shellHook = ''
      ${self.checks.${system}.pre-commit-check.shellHook}
    '';
  };
}
