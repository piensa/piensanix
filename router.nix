{ lib, config, pkgs, ...}:

{


 networking = {
    wireless.enable = false;
    networkmanager.enable = false;
    nameservers = [ "1.1.1.1" "8.8.8.8"];
    hostName = "oxygen";
    hostId = "c809225e";
    extraHosts = ''
      127.0.0.1 oxygen
    '';

    defaultGateway = "";
    interfaces = {
      enp6s0.ipv4.addresses = [{ address = "10.0.0.1"; prefixLength = 24; }];
      enp3s0.ipv4.addresses = [{ address = ""; prefixLength = 29; }];
    #  enp2s0 = { useDHCP = true; };
    };

    firewall = {
      enable = lib.mkForce true;
      allowPing = true;
      logRefusedConnections = false;
      rejectPackets = false;
      allowedTCPPortRanges = [
           { from = 80; to = 80; }
           { from = 443; to = 444; }
      ];
      trustedInterfaces = ["enp6s0"];
      extraCommands = ''
        iptables  -I INPUT -p tcp -m tcp --dport 22 ! -s 10.0.0.1/24 -j nixos-fw-log-refuse
      '';
    };

   nat = {
     enable = true;
      externalInterface = "enp3s0";
      internalInterfaces = ["enp6s0"];
      forwardPorts = [
      ];
    };
 };



}
