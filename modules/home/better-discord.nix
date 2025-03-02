{
  config,
  lib,
  pkgs,
  ...
}: {
  options.programs.better-discord = {
    enable = lib.mkEnableOption "BetterDiscord";

    themes = lib.mkOption {
      type = with lib.types;
        listOf (submodule {
          options = {
            id = lib.mkOption {
              type = lib.types.nullOr lib.types.int;
              default = null;
              description = "ID of the theme from betterdiscord.app (leave null for custom URLs)";
            };
            url = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              description = "Direct URL to download the theme (optional, overrides ID if set)";
            };
          };
        });
      default = [];
      description = "List of BetterDiscord themes to install (via ID or URL).";
    };

    plugins = lib.mkOption {
      type = with lib.types;
        listOf (submodule {
          options = {
            id = lib.mkOption {
              type = lib.types.nullOr lib.types.int;
              default = null;
              description = "ID of the plugin from betterdiscord.app (leave null for custom URLs)";
            };
            url = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              description = "Direct URL to download the plugin (optional, overrides ID if set)";
            };
          };
        });
      default = [];
      description = "List of BetterDiscord plugins to install (via ID or URL).";
    };
  };

  config =
    lib.mkIf config.programs.better-discord.enable {
      home.packages = with pkgs; [
        discord
        better-discord
        curl
      ];

      # Create BetterDiscord directories and download themes/plugins
      home.activation.downloadBetterDiscordAddons = lib.hm.dag.entryAfter ["writeBoundary"] ''
        # Set BetterDiscord directory for macOS
        BD_DIR="${config.home.homeDirectory}/Library/Application Support/BetterDiscord"
        THEMES_DIR="$BD_DIR/themes"
        PLUGINS_DIR="$BD_DIR/plugins"

        # Ensure directories exist
        mkdir -p "$THEMES_DIR"
        mkdir -p "$PLUGINS_DIR"

        # Collect config-defined filenames
        CONFIG_THEMES=()
        CONFIG_PLUGINS=()

        # Process themes
        ${lib.concatMapStrings (theme: ''
            FILE="$THEMES_DIR/''${theme.id}.theme.css"
            if [ -n "${theme.url}" ]; then
              FILE="$THEMES_DIR/$(basename ${theme.url})"
            fi

            CONFIG_THEMES+=("$FILE")

            if [ ! -f "$FILE" ]; then
              echo "Downloading theme: $FILE"
              ${lib.optionalString (theme.url != null) ''
              ${pkgs.curl}/bin/curl -JL -o "$FILE" "${theme.url}"
            ''}
              ${lib.optionalString (theme.id != null) ''
              ${pkgs.curl}/bin/curl -JL -o "$FILE" "https://betterdiscord.app/Download?id=${theme.id}"
            ''}
            else
              echo "Theme already exists: $FILE"
            fi
          '')
          config.programs.better-discord.themes}

        # Process plugins
        ${lib.concatMapStrings (plugin: ''
            FILE="$PLUGINS_DIR/''${plugin.id}.plugin.js"
            if [ -n "${plugin.url}" ]; then
              FILE="$PLUGINS_DIR/$(basename ${plugin.url})"
            fi

            CONFIG_PLUGINS+=("$FILE")

            if [ ! -f "$FILE" ]; then
              echo "Downloading plugin: $FILE"
              ${lib.optionalString (plugin.url != null) ''
              ${pkgs.curl}/bin/curl -JL -o "$FILE" "${plugin.url}"
            ''}
              ${lib.optionalString (plugin.id != null) ''
              ${pkgs.curl}/bin/curl -JL -o "$FILE" "https://betterdiscord.app/Download?id=${plugin.id}"
            ''}
            else
              echo "Plugin already exists: $FILE"
            fi
          '')
          config.programs.better-discord.plugins}

        # Remove files not in the config
        for file in "$THEMES_DIR"/*; do
          if [[ ! " ''${CONFIG_THEMES[@]} " =~ " $file " ]]; then
            echo "Removing old theme: $file"
            rm "$file"
          fi
        done

        for file in "$PLUGINS_DIR"/*; do
          if [[ ! " ''${CONFIG_PLUGINS[@]} " =~ " $file " ]]; then
            echo "Removing old plugin: $file"
            rm "$file"
          fi
        done
      '';

      # Install BetterDiscord into Discord
      home.activation.installBetterDiscord = lib.hm.dag.entryAfter ["writeBoundary"] ''
        export PATH=${lib.makeBinPath [pkgs.nodejs pkgs.nodePackages.pnpm]}:$PATH

        # Ensure BetterDiscord directory exists in a writable location
        if [ ! -d "$HOME/.betterdiscord" ]; then
          mkdir -p "$HOME/.betterdiscord"
          cp -r ${pkgs.better-discord}/lib/better-discord/* "$HOME/.betterdiscord/"
        fi

        # Fix permissions
        chmod -R u+w "$HOME/.betterdiscord"

        # Inject BetterDiscord into Discord
        cd "$HOME/.betterdiscord"
        ${pkgs.nodePackages.pnpm}/bin/pnpm inject
      '';
    }
    // lib.mkIf (!config.programs.better-discord.enable) {
      # Uninstall BetterDiscord when disabled
      home.activation.removeBetterDiscord = lib.hm.dag.entryBefore ["writeBoundary"] ''
        echo "Disabling BetterDiscord..."

        BD_DIR="${config.home.homeDirectory}/Library/Application Support/BetterDiscord"
        DISCORD_RESOURCES_DIR="${config.home.homeDirectory}/Library/Application Support/discord"

        # Remove BetterDiscord files from Discord
        rm -rf "$BD_DIR"
        rm -rf "$DISCORD_RESOURCES_DIR/betterdiscord"

        # Reset Discord's original files if backup exists
        if [ -d "$DISCORD_RESOURCES_DIR/original" ]; then
          echo "Restoring original Discord files..."
          mv "$DISCORD_RESOURCES_DIR/original" "$DISCORD_RESOURCES_DIR"
        fi

        echo "BetterDiscord has been disabled."
      '';
    };
}
