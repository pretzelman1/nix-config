{
  config,
  lib,
  ...
}: {
  imports = lib.flatten [
    ./sketchybar.nix
  ];
}
