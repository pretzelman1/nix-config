{ pkgs, ... }: {
  home.packages = with pkgs; [
    jupyter-all
  ];
}
