{
  cfg,
  lib,
  ...
}: let
  toPfPorts = ports:
    if ports == []
    then ""
    else "{ " + lib.concatStringsSep ", " (map toString ports) + " }";

  tcpIn = toPfPorts cfg.allowedInboundTCPPorts;
  udpIn = toPfPorts cfg.allowedInboundUDPPorts;

  icmp =
    if cfg.allowICMP
    then "pass inet proto icmp all"
    else "";
in ''
  # Default macOS PF anchors
  scrub-anchor "com.apple/*"
  nat-anchor "com.apple/*"
  rdr-anchor "com.apple/*"
  dummynet-anchor "com.apple/*"
  anchor "com.apple/*"
  load anchor "com.apple" from "/etc/pf.anchors/com.apple"

  set skip on lo0

  # Default block rules
  ${
    if cfg.blockAllInbound
    then "block in all"
    else ""
  }
  ${
    if cfg.blockAllOutbound
    then "block out all"
    else ""
  }

  # Allow all outbound if not blocked
  ${
    if !cfg.blockAllOutbound
    then "pass out all keep state"
    else ""
  }

  # Allow specific inbound ports
  ${
    if tcpIn != ""
    then "pass in proto tcp to port ${tcpIn} keep state"
    else ""
  }
  ${
    if udpIn != ""
    then "pass in proto udp to port ${udpIn} keep state"
    else ""
  }

  ${icmp}
''
