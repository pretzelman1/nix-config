{pkgs, ...}: {
  # Enable udisks2 service
  services.udisks2.enable = true;

  environment.systemPackages = with pkgs; [
    dolphin
    kdePackages.qtwayland # Wayland support
    kdePackages.qtsvg # SVG icon support
    kdePackages.kio-fuse # Mount remote filesystems via FUSE
    libsForQt5.kio-extras
    kdePackages.kio-extras # Extra protocols support (sftp, fish etc)
    kdePackages.ffmpegthumbs # Thumbnail support
    kdePackages.kio-extras-kf5 # Additional KIO protocols
    kdePackages.kdegraphics-thumbnailers # Additional thumbnail support
    udisks2 # For disk management
  ];
}
