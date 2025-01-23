{pkgs, ...}: {
  home.packages = with pkgs; [
    python3
    python3Packages.pip
    python3Packages.virtualenv
    poetry
  ];

  home.sessionVariables = {
    PYTHON_HOME = "${pkgs.python3}";
  };
}
