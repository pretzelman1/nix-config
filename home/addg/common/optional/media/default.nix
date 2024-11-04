{pkgs, ...}: {
  home.packages = builtins.attrValues {
    inherit
      (pkgs)
      ffmpeg
      spotify
      vlc
      ;
    inherit
      (pkgs.stable)
      calibre
      ;
  };
}
