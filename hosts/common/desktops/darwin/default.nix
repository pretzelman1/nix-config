{
  config,
  lib,
  ...
}: let
  appearance = config.desktops.appearance;
in {
  imports = lib.flatten [
    # (lib.custom.scanPaths ./.)
    # (lib.optional (builtins.pathExists ./${appearance}) ./${appearance})
    # ./${appearance}
  ];
}
