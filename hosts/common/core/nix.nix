{
  inputs,
  config,
  outputs,
  lib,
  ...
}: {
  nix = {
    # This will add each flake input as a registry
    # To make nix3 commands consistent with your flake
    # registry = lib.mapAttrs (_: value: { flake = value; }) inputs;

    # This will add your inputs to the system's legacy channels
    # Making legacy nix commands consistent as well, awesome!
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;

    settings = {
      # See https://jackson.dev/post/nix-reasonable-defaults/
      connect-timeout = 5;
      log-lines = 25;
      min-free = 128000000; # 128MB
      max-free = 1000000000; # 1GB

      experimental-features = [
        "nix-command"
        "flakes"
      ];
      warn-dirty = false;
    };

    optimise.automatic = true;

    gc.automatic = false;

    # Garbage Collection
    # Disabled here in favor of using nh based gc. See hosts/common/core/default.nix
    #    gc = {
    #      automatic = true;
    #      options = "--delete-older-than 10d";
    #    };
  };

  nixpkgs = {
    # you can add global overlays here
    overlays = [
      outputs.overlays.default
    ];
    # Allow unfree packages
    config = {
      allowUnfree = true;
    };
  };
}
