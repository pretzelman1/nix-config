{
  inputs,
  outputs,
  config,
  lib,
  ...
}: {
  imports = lib.flatten [
    (lib.custom.scanPaths ./.)
    # ../../users/root
  ];

  networking.hostName = config.hostSpec.hostName;
}
