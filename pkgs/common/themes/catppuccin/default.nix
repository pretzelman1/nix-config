{
  lib,
  callPackage,
  ...
}: {
  ghostty = callPackage ./ghostty/package.nix {};
  waybar = callPackage ./waybar/package.nix {};
}
