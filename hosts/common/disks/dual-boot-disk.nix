# Disk configuration for dual-booting NixOS and Windows
{
  lib,
  disk ? "/dev/vda",
  windowsSize ? "100G", # Size for Windows partition
  withSwap ? false,
  swapSize,
  config,
  mountWindows ? false, # New parameter with default value
  ...
}: {
  disko.devices = {
    disk = {
      disk0 = {
        type = "disk";
        device = disk;
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              priority = 1;
              name = "ESP";
              start = "1M";
              end = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = ["defaults"];
              };
            };
            # Windows partition (NTFS)
            windows = {
              name = "windows";
              priority = 2;
              size = windowsSize;
              type = "0700"; # Microsoft basic data partition type
              content = {
                type = "filesystem";
                format = "ntfs";
                # Not mounted by default in NixOS
                mountpoint = lib.mkIf mountWindows "/mnt/windows";
                mountOptions = ["defaults" "noatime"];
              };
            };
            # NixOS partition (BTRFS)
            nixos = {
              name = "nixos";
              priority = 3;
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
