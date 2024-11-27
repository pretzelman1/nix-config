{lib, ...}: rec {
  prefixLength = 24;

  ports.tcp.ssh = 22;

  hostsAddr = {
    # ============================================
    # Laptops
    # ============================================
    zephy = {
      ipv4 = "192.168.50.90";
    };
    k3s-master-1 = {
      ipv4 = "10.10.14.30";
    };
    k3s-master-2 = {
      ipv4 = "10.10.14.31";
    };
    k3s-master-3 = {
      ipv4 = "10.10.14.32";
    };
    k3s-node-1 = {
      ipv4 = "10.10.14.34";
    };
    k3s-node-2 = {
      ipv4 = "10.10.14.35";
    };
  };

  hostsInterface =
    lib.attrsets.mapAttrs
    (
      key: val: {
        interfaces."${val.iface}" = {
          useDHCP = false;
          ipv4.addresses = [
            {
              inherit prefixLength;
              address = val.ipv4;
            }
          ];
        };
      }
    )
    hostsAddr;

  ssh = {
    # define the host alias for remote builders
    # this config will be written to /etc/ssh/ssh_config
    # ''
    #   Host ruby
    #     HostName 192.168.5.102
    #     Port 22
    #
    #   Host kana
    #     HostName 192.168.5.103
    #     Port 22
    #   ...
    # '';
    extraConfig =
      lib.attrsets.foldlAttrs
      (acc: host: val:
        acc
        + ''
          Host ${host}
            HostName ${val.ipv4}
            Port 22
        '')
      ""
      hostsAddr;

    # define the host key for remote builders so that nix can verify all the remote builders
    # this config will be written to /etc/ssh/ssh_known_hosts
    knownHosts =
      # Update only the values of the given attribute set.
      #
      #   mapAttrs
      #   (name: value: ("bar-" + value))
      #   { x = "a"; y = "b"; }
      #     => { x = "bar-a"; y = "bar-b"; }
      lib.attrsets.mapAttrs
      (host: value: {
        hostNames = [host hostsAddr.${host}.ipv4];
        publicKey = value.publicKey;
      })
      {
        # ruby.publicKey = "";
        # kana.publicKey = "";
      };
  };
}
