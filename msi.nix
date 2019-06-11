{ config, lib, pkgs, ... }:

{
  boot.initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  time.timeZone = "America/Bogota";

  services.xserver.videoDrivers = [ "intel" ];
  systemd.services.nvidia-control-devices = {
    wantedBy = [ "multi-user.target" ];
    serviceConfig.ExecStart = "/run/current-system/sw/bin/nvidia-smi";
  };

  fileSystems."/" =
    { device = "/dev/disk/by-label/nixos";
      fsType = "btrfs";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-label/boot";
      fsType = "vfat";
    };

  swapDevices = [ ];

  nix.maxJobs = lib.mkDefault 8;
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.useOSProber = true;

  networking = {
     hostName = "msi";
     nameservers = [ "1.1.1.1" "8.8.8.8"];
     extraHosts = ''
     127.0.0.1 msi
     '';
     firewall = {
        enable = true;
        allowedTCPPortRanges = [
           { from = 80; to = 80; }
           { from = 443; to = 444; }
         ];
        allowPing = true;
     };
  };


  environment.systemPackages = with pkgs; [
     wget vim git
     pciutils file cudatoolkit vlc
     tmux htop ripgrep unzip
     tcpdump telnet openssh
  ];

  services.openssh = {
    enable = true;
    ports = [ 444 ];
    gatewayPorts = "yes";
    passwordAuthentication = false; 
    permitRootLogin = "no";
  };

  nixpkgs.config.allowUnfree = true;


  services.nginx = {
    enable = true;
    package = pkgs.nginx;

    config = ''
   events {
    worker_connections  4096;
   }

   http {
    include       ${pkgs.nginx}/conf/mime.types;
    default_type  application/octet-stream;
  
    server {
     listen 443 ssl http2;
     server_name puerti.co *.puerti.co;
     ssl_certificate /var/lib/acme/wild/live/puerti.co/fullchain.pem;
     ssl_certificate_key /var/lib/acme/wild/live/puerti.co/privkey.pem;
     add_header Strict-Transport-Security "max-age=15768000; includeSubDomains" always;
    
     ssl_protocols TLSv1.2 TLSv1.3;
     ssl_prefer_server_ciphers on;
     ssl_ciphers "EECDH+ECDSA+AESGCM EECDH+aRSA+AESGCM EECDH+ECDSA+SHA384 EECDH+aRSA+SHA384 !aNULL !eNULL !LOW !3DES !MD5 !EXP !PSK !SRP !DSS";
     ssl_session_cache shared:ssl_session_cache:10m;

     location / {
       proxy_set_header Host $host;
       proxy_pass http://sc.puerti.co/;
      }

    }
   }
  '';
  };


  
}
