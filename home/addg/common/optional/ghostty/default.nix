{
  pkgs,
  lib,
  ...
}: {
  xdg.configFile."ghostty/config".source = ./config;

  home.packages = lib.optionals (!pkgs.stdenv.isDarwin) [
    pkgs.ghostty
  ];
}
