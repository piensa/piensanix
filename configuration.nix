{ config, pkgs, ... }:

{
  imports =
    [ 
      ./hardware-configuration.nix
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.useOSProber = true;

  #networking.hostName = "";
  networking.networkmanager.enable = true;

  time.timeZone = "America/Bogota";

  environment.systemPackages = with pkgs; [
    # server
    wget vim tmux htop git ripgrep
    # code
    firefox kmail vscode vlc
    # design
    # blender godot gimp inkscape
  ];


  sound.enable = true;
  hardware.pulseaudio.enable = true;
  hardware.bluetooth.enable = true;
  services.xserver.enable = true;
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.displayManager.sddm.autoLogin.enable = true;
  services.xserver.displayManager.sddm.autoLogin.user = "x";
  services.xserver.desktopManager.plasma5.enable = true;

  users.users.x = {
    isNormalUser = true;
    home = "/x";
    description = "x";
    extraGroups = ["wheel" "networkmanager"];
  };

  nixpkgs.config = {
    allowUnfree = true;
  };

  system.stateVersion = "18.09";
}
