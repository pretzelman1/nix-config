{
  lib,
  configVars,
  ...
}: {
  macosSystem = import ./macosSystem.nix;
  nixosSystem = import ./nixosSystem.nix;

  # use path relative to the root of the project
  relativeToRoot = lib.path.append ../.;
  relativeToHome = lib.path.append ../home;
  relativeToHosts = lib.path.append ../hosts;

  getHomeDirectory = username:
    if (builtins.match ".*darwin" builtins.currentSystem != null)
    then "/Users/${username}"
    else "/home/${username}";

  scanPaths = path:
    builtins.map (f: (path + "/${f}")) (
      builtins.attrNames (
        lib.attrsets.filterAttrs (
          path: _type:
            (_type == "directory") # include directories
            || (
              (path != "default.nix") # ignore default.nix
              && (lib.strings.hasSuffix ".nix" path) # include .nix files
            )
        ) (builtins.readDir path)
      )
    );
}
