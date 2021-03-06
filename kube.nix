{ config, pkgs, lib, domain, ... }:

let
   domain = "puerti.co";
in {

  networking.extraHosts = ''
    127.0.0.1 ${domain} .${domain}
    127.0.0.1 master.${domain}
  '';

  networking.firewall.allowedTCPPorts = [ 80 443 ];
  virtualisation.docker.enable = true;
  environment.systemPackages = with pkgs; [
    kubectl
    kompose
    docker-compose
  ];

  services.caddy = {
    enable = true;
    email = "ariel@piensa.co";
    agree = true;
    config = ''
     ${domain} {
        gzip
        log syslog
        root /d/${domain}
     }
     geonode.${domain} {
       log syslog
       proxy / localhost:81 {
	transparent
       }
     } 
  '';
  };

  #services.kubernetes = {
  # easyCerts = true;
  # roles = ["master" "node"];
  # masterAddress = "master.${domain}";
  #};

  # Temporary off-nixpkgs tree fix, see
  # https://github.com/NixOS/nixpkgs/issues/60687
  #systemd.services.kube-control-plane-online.preStart =
  # let
  #  cfg = config.services.kubernetes;
  # in lib.mkForce ''
  # until curl -k -Ssf ${cfg.apiserverAddress}/healthz; do
  #    echo curl -k -Ssf ${cfg.apiserverAddress}/healthz: exit status $?
  #    sleep 3
  #  done
 #
 # '';
}

