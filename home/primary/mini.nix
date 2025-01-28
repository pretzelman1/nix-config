{lib, ...}: {
  imports = [
    #################### Required Configs ####################
    common/core

    #################### Host-specific Optional Configs ####################
    common/optional/helper-scripts
    common/optional/development/java.nix
    common/optional/darwin/aerospace
    common/optional/jupyter-notebook
    common/optional/media/spotify.nix
    common/optional/comms
    common/optional/development/ide.nix
    common/optional/development/tilt.nix
    common/optional/development/node.nix
    common/optional/development/misc-language-servers.nix
    common/optional/ghostty
  ];
}
