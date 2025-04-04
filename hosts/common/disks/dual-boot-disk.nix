# Disk configuration for dual-booting NixOS and Windows
# This configuration preserves existing Windows partitions
{
  lib,
  disk ? "/dev/vda",
  withSwap ? false,
  swapSize,
  config,
  ...
}: {
  disko.devices = {
    disk = {
      disk0 = {
        type = "disk";
        # Use disk ID instead of device name for stability
        device = disk;
        content = {
          type = "gpt";
          partitions = {
            # NixOS partition (BTRFS)
            # Start after Windows partitions (typically Windows uses ~500GB)
            nixos = {
              name = "nixos";
              # This is the key - start after Windows partitions
              # Adjust this value based on your Windows partition size
              start = "500G";
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = ["-f"]; # Override existing partition
                subvolumes = {
                  "@root" = {
                    mountpoint = "/";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                    ];
                  };
                  "@persist" = {
                    mountpoint = "${config.hostSpec.persistFolder}";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                    ];
                  };
                  "@nix" = {
                    mountpoint = "/nix";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                    ];
                  };
                  "@swap" = lib.mkIf withSwap {
                    mountpoint = "/.swapvol";
                    swap.swapfile.size = "${swapSize}G";
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
