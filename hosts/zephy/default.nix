#############################################################
#
#  zephy - Main Desktop
#  NixOS running on Ryzen 5 3600X, Radeon RX 5700 XT, 64GB RAM
#
###############################################################
{
  inputs,
  lib,
  configVars,
  configLib,
  pkgs,
  ...
}: {
  imports = lib.flatten [
    #################### Every Host Needs This ####################
    ./hardware-configuration.nix

    #################### Hardware Modules ####################
    inputs.hardware.nixosModules.common-cpu-amd
    inputs.hardware.nixosModules.common-gpu-amd
    inputs.hardware.nixosModules.common-pc-ssd

    #################### Disk Layout ####################
    inputs.disko.nixosModules.disko
    (configLib.relativeToHosts "common/nixos/disks/standard-disk-config.nix")
    {
      _module.args = {
        disk = "/dev/nvme0n1";
        withSwap = false;
      };
    }

    #################### Misc Inputs ####################
    inputs.stylix.nixosModules.stylix

    (map configLib.relativeToHosts [
      #################### Required Configs ####################
      "common/core"
      "common/nixos/core"

      #################### Host-specific Optional Configs ####################
      "common/nixos/optional/services/openssh.nix" # allow remote SSH access
      "common/nixos/optional/nvtop.nix" # GPU monitor (not available in home-manager)
      "common/nixos/optional/plymouth.nix" # fancy boot screen

      #################### Desktop ####################
      "common/nixos/optional/services/greetd.nix" # display manager
      "common/nixos/optional/hyprland.nix" # window manager
      "common/nixos/optional/thunar.nix" # file manager
      "common/nixos/optional/wayland.nix" # wayland components and pkgs not available in home-manager

      "common/users/addg"
    ])
  ];

  networking = {
    hostName = "zephy";
    networkmanager.enable = true;
    enableIPv6 = false;
  };

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
    timeout = 3;
  };

  boot.initrd = {
    systemd.enable = true;
  };

  # needed unlock LUKS on secondary drives
  # use partition UUID
  # https://wiki.nixos.org/wiki/Full_Disk_Encryption#Unlocking_secondary_drives
  environment.etc.crypttab.text = lib.optionalString (!configVars.isMinimal) ''
    cryptextra UUID=d90345b2-6673-4f8e-a5ef-dc764958ea14 /luks-secondary-unlock.key
    cryptvms UUID=ce5f47f8-d5df-4c96-b2a8-766384780a91 /luks-secondary-unlock.key
  '';

  #TODO:(stylix) move this stuff to separate file but define theme itself per host
  # host-wide styling
  stylix = {
    enable = true;
    image = "${configLib.getHomeDirectory}/Downloads/Mountain Lake Painting.jpg";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-hard.yaml";
    # base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-medium.yaml";
    #      cursor = {
    #        package = pkgs.foo;
    #        name = "";
    #      };
    #     fonts = {
    #monospace = {
    #    package = pkgs.foo;
    #    name = "";
    #};
    #sanSerif = {
    #    package = pkgs.foo;
    #    name = "";
    #};
    #serif = {
    #    package = pkgs.foo;
    #    name = "";
    #};
    #    sizes = {
    #        applications = 12;
    #        terminal = 12;
    #        desktop = 12;
    #        popups = 10;
    #    };
    #};
    opacity = {
      applications = 1.0;
      terminal = 1.0;
      desktop = 1.0;
      popups = 0.8;
    };
    polarity = "dark";
    # program specific exclusions
    #targets.foo.enable = false;
  };
  #hyprland border override example
  #  wayland.windowManager.hyprland.settings.general."col.active_border" = lib.mkForce "rgb(${config.stylix.base16Scheme.base0E});

  system.stateVersion = configVars.system.stateVersion;
}
