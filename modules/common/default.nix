# Add your reusable common modules to this directory, on their own file (https://wiki.nixos.org/wiki/NixOS_modules).
# These are modules not specific to either nixos, darwin, or home-manger that you would share with others, not your personal configurations.
{
  lib,
  isDarwin,
  ...
}: let
  platform =
    if isDarwin
    then "darwin"
    else "nixos";
in {
  imports = lib.flatten [
    (lib.custom.scanPaths ./.)
    ./${platform}
  ];
}
