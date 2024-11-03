let
  shellAliases = {
    "t" = "tmux";
  };
in {
  programs.tmux = {
    enable = true;
    tmuxinator.enable = true;
    tmuxp.enable = true;
    mouse = true;
    extraConfig = ''
      ${builtins.readFile ./tmux.conf}
    '';
  };
  home.shellAliases = shellAliases;
  programs.nushell.shellAliases = shellAliases;
}
