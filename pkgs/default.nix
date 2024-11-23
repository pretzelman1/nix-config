# You can build these directly using 'nix build .#example'
{pkgs ? import <nixpkgs> {}}: rec {
  #################### Packages with external source ####################
  fzf-git = pkgs.callPackage ./programs/fzf-git.nix {};
}
