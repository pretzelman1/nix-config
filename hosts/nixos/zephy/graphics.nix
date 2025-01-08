{ pkgs, lib, inputs, ...}:
{
    # https://medium.com/@notquitethereyet_/gaming-on-nixos-%EF%B8%8F-f98506351a24

    imports = [
        inputs.hardware.nixosModules.common-gpu-nvidia
    ];

    hardware.nvidia.prime = {
        offload = {
            enable = true;
            enableOffloadCmd = true; # Lets you use `nvidia-offload %command%` in steam
        };
        
        amdgpuBusId = "PCI:6:0:0"; # Correct the format to include the full structure
        nvidiaBusId = "PCI:01:00:0";
    };

    hardware.graphics = {
        enable = true;
    };

    services.xserver.videoDrivers = ["nvidia"];

    hardware.nvidia.modesetting.enable = true;

    services = {
        asusd.enable = lib.mkDefault true;
    };
}