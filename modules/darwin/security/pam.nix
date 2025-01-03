{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.security.pam;

  # Implementation Notes
  #
  # We don't use `environment.etc` because this would require that the user manually delete
  # `/etc/pam.d/sudo` which seems unwise given that applying the nix-darwin configuration requires
  # sudo. We also can't use `system.patchs` since it only runs once, and so won't patch in the
  # changes again after OS updates (which remove modifications to this file).
  #
  # As such, we resort to line addition/deletion in place using `sed`. We add a comment to the
  # added line that includes the name of the option, to make it easier to identify the line that
  # should be deleted when the option is disabled.
  mkSudoWatchIDAuthScript = isEnabled: let
    file =
      if lib.versionAtLeast pkgs.stdenv.targetPlatform.darwinMinVersion "14"
      then "/etc/pam.d/sudo_local"
      else "/etc/pam.d/sudo";
    option = "security.pam.enableSudoWatchIDAuth";
    sed = "${pkgs.gnused}/bin/sed";
    curl = "${pkgs.curl}/bin/curl";
    bash = "${pkgs.bash}/bin/bash";
  in ''
    ${
      if isEnabled
      then ''
        # Install pam-watchid if not already installed
        if ! test -f /usr/local/lib/pam/pam_watchid.so; then
          echo "Installing pam-watchid..."
          ${bash} -c "$(${curl} -fsSL https://raw.githubusercontent.com/logicer16/pam-watchid/HEAD/install.sh)" -- enable
        fi

        # Enable sudo Watch ID authentication, if not already enabled
        if ! grep 'pam_watchid.so' ${file} > /dev/null; then
          if [ ! -f ${file} ]; then
            # Create sudo_local if it doesn't exist (macOS 14+)
            touch ${file}
          fi
          ${sed} -i '1i\
        auth       sufficient     pam_watchid.so # nix-darwin: ${option}
          ' ${file}
        fi
      ''
      else ''
        # Disable sudo Watch ID authentication, if added by nix-darwin
        if grep '${option}' ${file} > /dev/null; then
          ${sed} -i '/${option}/d' ${file}
        fi
      ''
    }
  '';
in {
  options = {
    security.pam.enableSudoWatchIDAuth =
      mkEnableOption ""
      // {
        description = ''
          Enable sudo authentication with Watch ID.

          When enabled, this option:
          1. Installs pam-watchid if not already installed
          2. Adds the following line to the appropriate PAM config file:
             - For macOS 14+: {file}`/etc/pam.d/sudo_local`
             - For macOS 13 and earlier: {file}`/etc/pam.d/sudo`

          ```
          auth       sufficient     pam_watchid.so
          ```

          ::: {.note}
          macOS resets the sudo PAM config when doing a system update. As such, sudo
          authentication with Watch ID won't work after a system update
          until the nix-darwin configuration is reapplied.
          :::
        '';
      };
  };

  config = {
    system.activationScripts.pam.text = ''
      # PAM settings
      echo >&2 "setting up pam..."
      ${mkSudoWatchIDAuthScript cfg.enableSudoWatchIDAuth}
    '';
  };
}
