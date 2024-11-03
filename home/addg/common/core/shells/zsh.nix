{ config
, pkgs
, pkgs-unstable
, ...
}:
let
  shellAliases = {
    k = "kubectl";

    urldecode = "python3 -c 'import sys, urllib.parse as ul; print(ul.unquote_plus(sys.stdin.read()))'";
    urlencode = "python3 -c 'import sys, urllib.parse as ul; print(ul.quote_plus(sys.stdin.read()))'";
  };

  localBin = "${config.home.homeDirectory}/.local/bin";
  goBin = "${config.home.homeDirectory}/go/bin";
  rustBin = "${config.home.homeDirectory}/.cargo/bin";
in
{
  programs.zsh = {
    enable = true;

    plugins = [
      {
        name = "vi-mode";
        src = pkgs.zsh-vi-mode;
        file = "share/zsh-vi-mode/zsh-vi-mode.plugin.zsh";
      }
    ];

    oh-my-zsh = {
      enable = true;
      theme = "agnoster";
      plugins = [
        "encode64"
        "extract"
        "history"
        "jira"
        "last-working-dir"
        "lpass"
        "screen"
        "sdk"
        "ssh-agent"
        "ssh"
        "sudo"
        "vscode"
        "web-search"
        "aws"
        "brew"
        "mongocli"
        "redis-cli"
        "git"
        "git-auto-fetch"
        "github"
        "gitignore"
        "gh"
        "rust"
        "node"
        "nvm"
        "nodenv"
        "npm"
        "yarn"
        "dbt"
        "pip"
        "pipenv"
        "pyenv"
        "python"
        "pylint"
        "docker-compose"
        "docker"
        "composer"
        "helm"
        "kubectl"
        "kube-ps1"
        "microk8s"
        "minikube"
        "terraform"
      ];
    };

    enableCompletion = true;
    syntaxHighlighting = {
      enable = true;
      highlighters = [
        "brackets"
      ];
      styles = {
        comment = "fg=black,bold";
      };
    };
    autosuggestion = {
      enable = true;
      # highlight = "fg=#ff00ff,bg=cyan,bold,underline";
    };

    shellAliases = {
      "k" = "kubectl";
      "t" = "tmux";
      "td" = "default_tmux_session";
      "tf" = "terraform";
    };

    initExtra = ''
      _fzf_comprun() {
          local command=$1
          shift

          case "$command" in
          cd) fzf --preview 'eza --tree --color=always {} | head -200' "$@" ;;
          export|unset) fzf --preview "eval 'echo \$' {}" "$@" ;;
          ssh) fzf --preview 'dig {}' "$@" ;;
          *) fzf --preview "'bat -n --color=always --style=numbers --line-range=:500 {}'" "$@" ;;
          esac
      }

      _fzf_compgen_path() {
          fd --hidden --exclude ".git" . "$1"
      }

      _fzf_compgen_dir() {
          fd --type d --hidden --exclude ".git" . "$1"
      }

      if command -v ngrok &>/dev/null; then
          eval "$(ngrok completion)"
      fi

      function default_tmux_session() {
          if command -v tmux &> /dev/null && [ -z "$TMUX" ]; then
              if timeout 1s tmux has-session -t default 2>/dev/null; then
                  tmux attach-session -t default
              else
                  exit_status=$?
                  if [ $exit_status -eq 124 ]; then
                      echo "Operation timed out"
                      exit 1
                  else
                      tmux new-session -s default -c "$PWD"
                  fi
              fi
          fi
      }

      function toggle_internet_checker() {
          # Attempt to enable the internet checker and capture the output
          output=$(launchctl load ~/Library/LaunchAgents/com.addg0.checkinternet.plist 2>&1)

          # Check if the load command was successful or if it failed with a specific error
          if echo "$output" | grep -q "Load failed: 5: Input/output error"; then
              launchctl unload ~/Library/LaunchAgents/com.addg0.checkinternet.plist 2>/dev/null
              echo "Internet checks are now disabled."
          else
              echo "Internet checks are now enabled."
          fi
      }
    '';
  };

  programs.oh-my-posh = {
    enable = true;
    enableZshIntegration = true;
    settings = builtins.fromJSON (builtins.unsafeDiscardStringContext (builtins.readFile ./oh-my-posh-config.json));
  };
}
