{ config, lib, pkgs, ... }:

{
  imports =
    [ <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
  ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

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

  networking.hostName = "msi";

  nixpkgs.overlays = [
    (self: super:
    let
      inherit (self.pkgs) fetchgit python37Packages;
      inherit (python37Packages) numpy python;
    in {
      blender = (super.blender.override {
      pythonPackages = python37Packages;
      cudaSupport = true;
    }).overrideAttrs (oldAttrs: rec {
      name = "blender-2.80.beta-${version}";
      version = "38984b10ff7b8c61c5e1b85a971c77841de5f4e7";

      src = fetchgit {
        url = "https://git.blender.org/blender.git";
        rev = version;
        sha256 = "1i1i7bvr293g96hq5vazk2g25kz4hv4qbqhffp84lscb21d395bp";
      };

      cmakeFlags = oldAttrs.cmakeFlags ++ [
        "-DPYTHON_NUMPY_PATH=${numpy}/${python.sitePackages}"
        "-DWITH_PYTHON_INSTALL=ON"
        "-DWITH_PYTHON_INSTALL_NUMPY=ON"
      ];
     });
    }
    ) 
  ];

  environment.systemPackages = with pkgs; [
     wget vim git
     pciutils file cudatoolkit
     tmux htop ripgrep unzip
     tcpdump telnet openssh
     gnumake gcc libcxx libcxxabi llvm ninja clang
     python3 nodejs nodePackages.node2nix go
     firefox kmail vscode vlc
     blender godot gimp inkscape krita audacity
     libreoffice

     minio-client
  ];

  systemd.services.nvidia-control-devices = {
    wantedBy = [ "multi-user.target" ];
    serviceConfig.ExecStart = "/run/current-system/sw/bin/nvidia-smi";
  };

  nixpkgs.config.allowUnfree = true;

  services.xserver.videoDrivers = [ "nvidia" ];
  services.xserver.enable = true;
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;
  services.xserver.displayManager.sddm.autoLogin.enable = true;
  services.xserver.displayManager.sddm.autoLogin.user = "x";

  users.users.x = {
    isNormalUser = true;
    home = "/x";
    extraGroups = ["libvirtd"];
    openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC2SGK2vk4KGjkqUcDEdBYwHLj9utMTTShyPYAWBQx8jL0ezUoHqPl7ChJqLuI2ZWMVTW2QnGHl2oZjJRK6ngF0i9hhpjjONEHOdK9YHHaXeUXgad0mAT1R+365jIR1PYOvx9kC7pk8V1Iw3EHmnRRlAHtH19sAfGiyUopZ/N2gjVE0QMhotlKjwDlG9mQR/iFJq604R/nvAvTNXgHuuVou25t1kJkGNxAbiy3jOjKQHlR4NTTB2ttAtodJDU45+FNIWOiZYLbolYdAt9VLIYngDv9aSbxUCsF2ObHZ+Ovqmx0+BK1EKkZ01SYgwIQp3Nfk09xx03y28oFlvG+O6GX3 x@xs-MacBook.local" ];

  };

  system.stateVersion = "18.09"; 
}
