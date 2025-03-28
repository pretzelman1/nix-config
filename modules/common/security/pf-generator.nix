{
  cfg,
  lib,
}: let
  toPfPorts = ports:
    if ports == []
    then ""
    else "{ " + lib.concatStringsSep ", " ports + " }";

  tcpIn = toPfPorts cfg.allowedInboundTCPPorts;
  udpIn = toPfPorts cfg.allowedInboundUDPPorts;
  tcpOut = toPfPorts cfg.allowedOutboundTCPPorts;
  udpOut = toPfPorts cfg.allowedOutboundUDPPorts;

  icmp =
    if cfg.allowICMP
    then "pass inet proto icmp all"
    else "";

  fromIPFilter = ip:
    if ip == "any"
    then "any"
    else ip;

  allowFrom =
    if cfg.allowFromIPs != []
    then lib.concatMapStringsSep "\n" (ip: "pass in from ${fromIPFilter ip} to any") cfg.allowFromIPs
    else "";
in ''
  set skip on lo0

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

  # Stateful rules
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
  ${
    if tcpOut != ""
    then "pass out proto tcp to port ${tcpOut} keep state"
    else ""
  }
  ${
    if udpOut != ""
    then "pass out proto udp to port ${udpOut} keep state"
    else ""
  }

  ${icmp}
  ${allowFrom}
''
