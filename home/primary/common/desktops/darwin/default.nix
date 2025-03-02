{
  config,
  lib,
  pkgs,
  inputs,
  desktops,
  ...
}: {
  imports =
    lib.flatten [
    ]
    ++ lib.optional (builtins.pathExists ./${desktops.appearance}) ./${desktops.appearance};
}
