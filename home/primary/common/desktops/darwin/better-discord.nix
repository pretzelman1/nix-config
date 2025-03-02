{
  config,
  lib,
  pkgs,
  ...
}: {
  programs.better-discord = {
    enable = true;
    themes = [
      {
        url = "https://raw.githubusercontent.com/catppuccin/discord/refs/heads/main/themes/mocha.theme.css";
      }
    ];
  };
}
