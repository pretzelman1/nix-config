{pkgs, ...}: let
  scripts = {
    linktree = pkgs.writeShellApplication {
      name = "linktree";
      runtimeInputs = [];
      text = builtins.readFile ./linktree.sh;
    };
    close-port = pkgs.writeShellApplication {
      name = "close-port";
      runtimeInputs = [];
      text = builtins.readFile ./close-port.sh;
    };
  };
in {
  home.packages = builtins.attrValues scripts;
}
