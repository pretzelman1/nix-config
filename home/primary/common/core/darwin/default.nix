{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = lib.custom.scanPaths ./.;

  # Install MacOS applications to the user environment if the targetPlatform is Darwin
  home.file."Applications/home-manager".source = let
    apps = pkgs.buildEnv {
      name = "home-manager-applications";
      paths = config.home.packages;
      pathsToLink = "/Applications";
    };
  in
    lib.mkIf pkgs.stdenv.targetPlatform.isDarwin "${apps}/Applications";

  home.packages = with pkgs; [
    pam-reattach
    utm # virtual machine
  ];

  home.activation.link-apps = lib.hm.dag.entryAfter ["linkGeneration"] ''
    new_nix_apps="${config.home.homeDirectory}/Applications/Nix"
    rm -rf "$new_nix_apps"
    mkdir -p "$new_nix_apps"
    find -H -L "$genProfilePath/home-files/Applications" -name "*.app" -type d -print | while read -r app; do
      real_app=$(readlink -f "$app")
      app_name=$(basename "$app")
      target_app="$new_nix_apps/$app_name"
      ${pkgs.mkalias}/bin/mkalias "$real_app" "$target_app"
    done
  '';
}
