{ pkgs, ... }: {
  home.packages = with pkgs.stable; [
    # Add Jupyter Notebook and its dependencies
    # jupyter
  ] ++ (with python312Packages; [
    # Optional but useful Jupyter-related packages
    jupyterlab  # A more advanced web interface for Jupyter
  ]);
}
