{
  pkgs,
  nix-secrets,
  config,
  ...
}: {
  home.packages = with pkgs; [
    awscli2
    ssm-session-manager-plugin
    kubelogin # AWS Kubernetes was complaining about not being able to find the plugin
  ];

  sops.secrets.aws_credentials = {
    format = "binary";
    sopsFile = "${nix-secrets}/secrets/shipperhq/aws-credentials.enc";
    path = "${config.home.homeDirectory}/.aws/credentials";
  };

  home.sessionVariables = {
    AWS_PAGER = "bat --paging=always --language=json";
  };
}
