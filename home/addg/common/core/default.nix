{
  config,
  lib,
  pkgs,
  outputs,
  configLib,
  inputs,
  nur-ryan4yin,
  ...
}:
{
  imports = (configLib.scanPaths ./.) ++ (builtins.attrValues outputs.homeManagerModules);

  # services.ssh-agent.enable = true;

  home = {
    username = lib.mkDefault "addg";
    homeDirectory = lib.mkDefault (configLib.getHomeDirectory config.home.username);
    stateVersion = lib.mkDefault "23.05";
    sessionPath = [
      "$HOME/.local/bin"
      "$HOME/scripts/talon_scripts"
    ];
    sessionVariables = {
      FLAKE = "$HOME/nix-config";
      SHELL = "zsh";
      TERM = "kitty";
      TERMINAL = "kitty";
      VISUAL = "nvim";
      EDITOR = "nvim";
      MANPAGER = "batman"; # see ./cli/bat.nix
    };
    preferXdgDirectories = true; # whether to make programs use XDG directories whenever supported

  };
  #TODO: maybe move this to its own xdg.nix?
  # xdg packages are pulled in below
  # xdg = {
  #   enable = true;
  #   userDirs = {
  #     enable = true;
  #     createDirectories = true;
  #     desktop = "${config.home.homeDirectory}/.desktop";
  #     documents = "${config.home.homeDirectory}/doc";
  #     download = "${config.home.homeDirectory}/downloads";
  #     music = "${config.home.homeDirectory}/media/audio";
  #     pictures = "${config.home.homeDirectory}/media/images";
  #     videos = "${config.home.homeDirectory}/media/video";
  #     # publicshare = "/var/empty"; #using this option with null or "/var/empty" barfs so it is set properly in extraConfig below
  #     # templates = "/var/empty"; #using this option with null or "/var/empty" barfs so it is set properly in extraConfig below

  #     extraConfig = {
  #       # publicshare and templates defined as null here instead of as options because
  #       XDG_PUBLICSHARE_DIR = "/var/empty";
  #       XDG_TEMPLATES_DIR = "/var/empty";
  #     };
  #   };
  # };

  home.packages = builtins.attrValues {
    inherit (pkgs)
      # Packages that don't have custom configs go here
      coreutils # basic gnu utils
      fd # tree style ls
      findutils # find
      jq # JSON pretty printer and manipulator
      neofetch # fancier system info than pfetch
     #  ncdu # TUI disk usage
      pciutils
      pfetch # system info
      pre-commit # git hooks
      p7zip # compression & encryption
      ripgrep # better grep
      # steam-run # for running non-NixOS-packaged binaries on Nix
      # usbutils
      tree # cli dir tree viewer
      unzip # zip extraction
      unrar # rar extraction
      xdg-utils # provide cli tools such as `xdg-mime` and `xdg-open`
      xdg-user-dirs
      # wev # show wayland events. also handy for detecting keypress codes
      wget # downloader
      zip # zip compression
      sops
      age

      # Misc
      spotify
      tldr
      cowsay
      gnupg
      gnumake
      ngrok
      mailsy # create and send emails from the terminal
      llm # chat with llm's from the terminal
      cpulimit # limit the cpu usage of a process

      # Modern cli tools, replacement of grep/sed/...
      fzf # Interactively filter its input using fuzzy searching, not limit to filenames.
      # fd and ripgrep are already included above
      sad # CLI search and replace, just like sed, but with diff preview.
      yq-go # yaml processor https://github.com/mikefarah/yq
      just # a command runner like make, but simpler
      delta # A viewer for git and diff output
      lazygit # Git terminal UI.
      hyperfine # command-line benchmarking tool
      gping # ping, but with a graph(TUI)
      doggo # DNS client for humans
      duf # Disk Usage/Free Utility - a better 'df' alternative
      du-dust # A more intuitive version of `du` in rust
      gdu # disk usage analyzer(replacement of `du`)

      # nix related
      nix-output-monitor # it provides the command `nom` works just like `nix with more details log output
      hydra-check # check hydra(nix's build farm) for the build status of a package
      nix-index # A small utility to index nix store paths
      nix-init # generate nix derivation from url
      nix-melt # A TUI flake.lock viewer
      nixpkgs-fmt # formatter for nixpkgs
      nix-tree # nix package tree viewer
      alejandra # nix formatter
      nixd # nix language server

      # productivity
      caddy # A webserver with automatic HTTPS via Let's Encrypt(replacement of nginx)
      croc # File transfer between computers securely and easily
      # ncdu is already included above

      ;
  };

  home.shellAliases = {
    nixpkgs-fmt = "alejandra";
  };

  nixpkgs = {
    overlays = builtins.attrValues outputs.overlays;
    config = {
      allowUnfree = true;
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = (_: true);
    };
  };

  nix = {
    package = lib.mkDefault pkgs.nix;
    nixPath = [
      "nixpkgs=${inputs.nixpkgs}"
    ];
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      warn-dirty = false;
    };
  };

  programs = {
    home-manager.enable = true; # Let home-manager manage itself
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";
}
