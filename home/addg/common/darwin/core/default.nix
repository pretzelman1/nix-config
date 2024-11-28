{
  configLib,
  config,
  lib,
  pkgs,
  ...
}: {
  imports = configLib.scanPaths ./.;

  # Install MacOS applications to the user environment if the targetPlatform is Darwin
  home.file."Applications/home-manager".source = let
    apps = pkgs.buildEnv {
      name = "home-manager-applications";
      paths = config.home.packages;
      pathsToLink = "/Applications";
    };
  in
    lib.mkIf pkgs.stdenv.targetPlatform.isDarwin "${apps}/Applications";

  # home.activation = {
  #   aliasApplications = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
  #     app_folder=$(echo ~/Applications);
  #     for app in $(find "$genProfilePath/home-path/Applications" -type l); do
  #       $DRY_RUN_CMD rm -f $app_folder/$(basename $app)
  #       $DRY_RUN_CMD osascript -e "tell app \"Finder\"" -e "make new alias file at POSIX file \"$app_folder\" to POSIX file \"$app\"" -e "set name of result to \"$(basename $app)\"" -e "end tell"
  #     done
  #   '';
  # };
}
