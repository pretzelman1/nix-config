{
  inputs,
  outputs,
  lib,
  ...
}: {
  imports = lib.flatten [
    (lib.custom.scanPaths ./.)
    # ../../users/root
  ];
}
