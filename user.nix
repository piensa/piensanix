{ config, pkgs, lib, ... }:
{
  fonts = {
    enableFontDir = true;
    enableGhostscriptFonts = true;
    fonts = with pkgs; [
      corefonts
      #vistafonts
      inconsolata
      terminus_font
      proggyfonts
      dejavu_fonts
      font-awesome-ttf
      ubuntu_font_family
      source-code-pro
      source-sans-pro
      source-serif-pro
    ];
  };


  nixpkgs.config = {
    allowUnfree = true;
    chromium = {
      enablePepperFlash = true;
    };
  };

  nix.extraOptions = ''
    keep-outputs = true
    keep-derivations = true
  '';
 
  programs.adb.enable = true;
  sound.enable = true;

  users.users.x = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "video" "docker" "adbusers" ];
    home = "/x";
    packages = with pkgs; [
      git vim mutt spectacle htop
      wget tmux htop git ripgrep unzip
      tcpdump telnet openssh
      sops
      firefox google-chrome
      keepass-with-plugins
      blender
      krita inkscape gimp godot
      qgis
      obs-studio obs-linuxbrowser
      darktable vlc
      libreoffice
      ncurses
      pciutils

      android-studio
   ];
  };

  environment.systemPackages = with pkgs; [
    wget
    vim
    tcpdump
    ripgrep
    exfat-utils
  ];

  networking.networkmanager.enable = true;
  networking.hostName = "oxygen";
  networking.nameservers = [ "1.1.1.1" "8.8.8.8"];
  networking.firewall.enable = false;
  time.timeZone = "America/Bogota";

}
