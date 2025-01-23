{
  config,
  lib,
  nix-secrets,
  ...
}: {
  sops.secrets = {
    kube_config = {
      format = "binary";
      sopsFile = "${nix-secrets}/secrets/kube.yaml.enc";
      path = "${config.home.homeDirectory}/.kube/config-home";
    };
  };

  programs.zsh.initExtra = ''
    export KUBECONFIG=${config.home.homeDirectory}/.kube/config:${config.sops.secrets.kube_config.path}
  '';
}
