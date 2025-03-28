{
  pkgs,
  nix-secrets,
  config,
  lib,
  ...
}: {
  home.packages = with pkgs; [
    awscli2
    ssm-session-manager-plugin
    saml2aws
  ];

  sops.secrets = {
    aws_credentials = {
      format = "binary";
      sopsFile = "${nix-secrets}/secrets/shipperhq/aws-credentials.enc";
      path = "${config.home.homeDirectory}/.aws/credentials";
    };
    aws_config = {
      format = "binary";
      sopsFile = "${nix-secrets}/secrets/shipperhq/aws-config.enc";
      path = "${config.home.homeDirectory}/.aws/config";
    };
  };

  home.sessionVariables = {
    AWS_PAGER = "bat --paging=always --language=json";
  };
}
