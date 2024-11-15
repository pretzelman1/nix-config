# colmena - Remote Deployment via SSH
{
  lib,
  nixpkgs,
  inputs,
  ...
} @ args: name: { system ? "x86_64-linux", tags ? [], ... } @ moduleArgs:
let
  pkgs = import nixpkgs {
    inherit system;
    config.allowUnfree = true;
  };
in
{
  inherit tags;  # Make sure tags are passed through

  deployment = {
    targetUser = "root";
    targetHost = moduleArgs.networking.hostName;
  };

  imports = [
    inputs.home-manager.nixosModules.home-manager
    {
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        extraSpecialArgs = { inherit inputs; } // moduleArgs;
      };
    }
    ../hosts/${name}
  ];

  _module.args = {
    inherit pkgs inputs;
  } // moduleArgs;
}
