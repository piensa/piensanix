{ config, lib, pkgs, ... }:

{
  
  imports =
    [ <nixpkgs/nixos/modules/hardware/network/broadcom-43xx.nix>
      <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    ];

  boot.initrd.availableKernelModules = [ 
    "xhci_pci" "ahci" "usb_storage"
     "usbhid" "sd_mod" "sdhci_pci"
  ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];
  virtualisation.libvirtd.enable = true;

  fileSystems."/" =
    { device = "/dev/disk/by-label/nixos";
      fsType = "btrfs";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-label/boot";
      fsType = "vfat";
    };

  swapDevices = [ { device = "/dev/disk/by-label/swap"; }];

  nix.maxJobs = lib.mkDefault 8;
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.useOSProber = true;

  system.stateVersion = "18.09"; 

  environment.systemPackages = with pkgs; [
    wget vim tmux htop git ripgrep
    gnumake gcc libcxx libcxxabi llvm ninja clang
    python3 nodejs go
    firefox kmail vscode vlc
    blender godot 
    gimp inkscape
    libreoffice
  ];

  nixpkgs.config = {
    allowUnfree = true;
  };

  networking.networkmanager.enable = true;
  networking.hostName = "x";
  time.timeZone = "America/Bogota";

  i18n = {
    consoleFont = "lat9w-16";
    consoleKeyMap = "es";
    defaultLocale = "en_US.UTF-8";
  };

  sound.enable = true;
  hardware.pulseaudio.enable = true;
  hardware.bluetooth.enable = true;
  services.xserver.enable = true;
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.displayManager.sddm.autoLogin.enable = true;
  services.xserver.displayManager.sddm.autoLogin.user = "x";
  services.xserver.desktopManager.plasma5.enable = true;
  services.xserver.layout = "es";

  hardware.sane.enable = true;
  hardware.sane.extraBackends=[ pkgs.samsung-unified-linux-driver_1_00_37 ];
  nix.readOnlyStore=false;
  services.printing.enable=true;
  services.printing.drivers=[ pkgs.samsung-unified-linux-driver_1_00_37 ];


  services.avahi.enable = true;
  services.avahi.publish.enable = true;
  services.avahi.publish.userServices = true;

  services.printing.browsing = true;
  services.printing.listenAddresses = [ "*:631" ];
  services.printing.defaultShared = true; # If you want

  networking.firewall.allowedUDPPorts = [ 631 ];
  networking.firewall.allowedTCPPorts = [ 631 ];

  users.users.x = {
    isNormalUser = true;
    home = "/x";
    extraGroups = ["networkmanager"];
  };

}

