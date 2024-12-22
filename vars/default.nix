{
  inputs,
  lib,
  ...
}: {
  #inherit (inputs.nix-secrets)
  #userFullName
  #domain
  #email
  # networking
  # ;
  userFullName = "addg0";

  networking = import ./networking.nix {inherit lib;};

  domain = "addg0.com";

  username = "addg";
  handle = "addg";
  gitHubEmail = "addgamer09@gmail.com";
  gitLabEmail = "addgamer09@gmail.com";
  persistFolder = "/persist";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  # https://wiki.nixos.org/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "24.11"; # Did you read the comment?

  # System-specific settings (FIXME: Likely make options)
  isMinimal = false; # Used to indicate nixos-installer build
  isWork = false; # Used to indicate a host that uses work resources
  scaling = "1"; # Used to indicate what scaling to use. Floating point number
}
