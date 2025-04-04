{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./options.nix
    ./config.nix
  ];
}
