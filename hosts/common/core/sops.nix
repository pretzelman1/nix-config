
{
  config,
  configLib,
  nix-secrets,
  ...
}: {
  # sops = {
  #   defaultSopsFile = "${nix-secrets}/secrets/secrets.yaml";

  #   age = {
  #     sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
  #     keyFile = "/var/lib/sops-nix/keys.txt";
  #     generateKey = true;
  #   };
  # };
}
