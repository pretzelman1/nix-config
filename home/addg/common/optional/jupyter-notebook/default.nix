{ pkgs, ... }: {
  home.packages = with pkgs.python312Packages; [
    pkgs.python312
    ipython
    ipykernel
    jupyter
    jupyterlab
  ];
}
