{
  pkgs,
  nix-secrets,
  config,
  lib,
  ...
}: {
  home.packages = with pkgs;
    [
      awscli2
      ssm-session-manager-plugin
    ]
    ++ lib.optionals pkgs.stdenv.hostPlatform.isDarwin [
      # aws-vpn-client
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
