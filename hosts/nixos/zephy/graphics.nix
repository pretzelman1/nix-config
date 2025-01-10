{
  pkgs,
  lib,
  inputs,
  config,
  ...
}: {
  # https://medium.com/@notquitethereyet_/gaming-on-nixos-%EF%B8%8F-f98506351a24

  # imports = [
  #   inputs.hardware.nixosModules.common-gpu-nvidia
  # ];

  # hardware.nvidia = {
  #   prime = {
  #     offload = {
  #       enable = true;
  #       enableOffloadCmd = true; # Lets you use `nvidia-offload %command%` in steam
  #     };

  #     amdgpuBusId = "PCI:6:0:0"; # Correct the format to include the full structure
  #     nvidiaBusId = "PCI:1:0:0";
  #   };
  #   modesetting.enable = true;
  # };

  # hardware.opengl.enable = true;

  hardware.nvidia = {
    # Modesetting is required.
    modesetting.enable = true;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    # Enable this if you have graphical corruption issues or application crashes after waking
    # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead
    # of just the bare essentials.
    powerManagement.enable = false;

    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = false;

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing and later architectures. Full list of
    # supported GPUs is at:
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus
    # Only available from driver 515.43.04+
    # Currently alpha-quality/buggy, so false is currently the recommended setting.
    open = false;

    # Enable the Nvidia settings menu,
    # accessible via `nvidia-settings`.
    nvidiaSettings = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # Enable OpenGL
  hardware.graphics = {
    enable = true;
  };

  services.supergfxd.enable = true;

  services.xserver.videoDrivers = ["nvidia"];

  services = {
    asusd = {
      enable = lib.mkDefault true;
      enableUserService = true;
    };
  };
}
