{pkgs, ...}: let
  scripts = {
    linktree = pkgs.writeShellApplication {
      name = "linktree";
      runtimeInputs = [];
      text = builtins.readFile ./linktree.sh;
    };
    close-port = pkgs.writeShellApplication {
      name = "close-port";
      runtimeInputs = with pkgs; [ lsof ];
      text = builtins.readFile ./close-port.sh;
    };
    toggle-internet = pkgs.writeShellApplication {
      name = "toggle-internet";
      runtimeInputs = with pkgs; [];
      text = builtins.readFile ./toggle-internet.sh;
    };
  };
in {
  home.packages = builtins.attrValues scripts;
}
