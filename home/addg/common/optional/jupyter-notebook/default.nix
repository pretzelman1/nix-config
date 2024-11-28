{pkgs, ...}: {
  home.packages = with pkgs; [
    jupyter-all
    python312Packages.jupyterlab-widgets
  ];
}
