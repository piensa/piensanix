{ config, lib, pkgs, ... }:

{
  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];
  
  nix.allowedUsers = [ "@users" ];
  nix.useSandbox = false;
  security.hideProcessInformation = true;
  # Setting this one to true is preferred but makes wifi not work on my  HP Envy.
  security.lockKernelModules = false;
  security.allowUserNamespaces = false;
  security.protectKernelImage = true;
  security.allowSimultaneousMultithreading = false;
  security.virtualization.flushL1DataCache = "always";

  boot.kernelPackages = pkgs.linuxPackages_hardened;

  boot.kernelParams = [
    # Slab/slub sanity checks, redzoning, and poisoning
    "slub_debug=FZP"

    # Disable slab merging to make certain heap overflow attacks harder
    "slab_nomerge"

    # Overwrite free'd memory
    "page_poison=1"

    # Disable legacy virtual syscalls
    "vsyscall=none"

    # Enable PTI even if CPU claims to be safe from meltdown
    "pti=on"

    # My AMD laptop
    "amd_iommu=pt" "ivrs_ioapic[32]=00:14.0" "iommu=soft"
  ];

  # Restrict ptrace() usage to processes with a pre-defined relationship
  # (e.g., parent/child)
  boot.kernel.sysctl."kernel.yama.ptrace_scope" = 1;

  # Restrict access to kernel ring buffer (information leaks)
  boot.kernel.sysctl."kernel.dmesg_restrict" = true;

  # Hide kptrs even for processes with CAP_SYSLOG
  #boot.kernel.sysctl."kernel.kptr_restrict" = 2;

  # Unprivileged access to bpf() has been used for privilege escalation in
  # the past
  boot.kernel.sysctl."kernel.unprivileged_bpf_disabled" = true;

  # Disable bpf() JIT (to eliminate spray attacks)
  boot.kernel.sysctl."net.core.bpf_jit_enable" = false;

  # ... or at least apply some hardening to it
  boot.kernel.sysctl."net.core.bpf_jit_harden" = true;

  # Allowing users to mmap() memory starting at virtual address 0 can turn a
  # NULL dereference bug in the kernel into code execution with elevated
  # privilege.  Mitigate by enforcing a minimum base addr beyond the NULL memory
  # space.  This breaks applications that require mapping the 0 page, such as
  # dosemu or running 16bit applications under wine.  It also breaks older
  # versions of qemu.
  #
  # The value is taken from the KSPP recommendations (Debian uses 4096).
  boot.kernel.sysctl."vm.mmap_min_addr" = 65536;

  # Disable ftrace debugging
  boot.kernel.sysctl."kernel.ftrace_enabled" = false;

  # Enable reverse path filtering (that is, do not attempt to route packets
  # that "obviously" do not belong to the iface's network; dropped packets are
  # logged as martians).
  boot.kernel.sysctl."net.ipv4.conf.all.log_martians" = true;
  boot.kernel.sysctl."net.ipv4.conf.all.rp_filter" = true;
  boot.kernel.sysctl."net.ipv4.conf.default.log_martians" = true;
  boot.kernel.sysctl."net.ipv4.conf.default.rp_filter" = true;

  # Ignore broadcast ICMP (mitigate SMURF)
  boot.kernel.sysctl."net.ipv4.icmp_echo_ignore_broadcasts" = true;

  # Ignore route information from sender
  boot.kernel.sysctl."net.ipv4.conf.all.accept_source_route" = false;
  boot.kernel.sysctl."net.ipv4.conf.default.accept_source_route" = false;
  boot.kernel.sysctl."net.ipv6.conf.all.accept_source_route" = false;
  boot.kernel.sysctl."net.ipv6.conf.default.accept_source_route" = false;

  # Ignore incoming ICMP redirects (note: default is needed to ensure that the
  # setting is applied to interfaces added after the sysctls are set)
  boot.kernel.sysctl."net.ipv4.conf.all.accept_redirects" = false;
  boot.kernel.sysctl."net.ipv4.conf.all.secure_redirects" = false;
  boot.kernel.sysctl."net.ipv4.conf.default.accept_redirects" = false;
  boot.kernel.sysctl."net.ipv4.conf.default.secure_redirects" = false;
  boot.kernel.sysctl."net.ipv6.conf.all.accept_redirects" = false;
  boot.kernel.sysctl."net.ipv6.conf.default.accept_redirects" = false;

  # Ignore outgoing ICMP redirects (this is ipv4 only)
  boot.kernel.sysctl."net.ipv4.conf.all.send_redirects" = false;
  boot.kernel.sysctl."net.ipv4.conf.default.send_redirects" = false;

  virtualisation.docker.enable = true;
  virtualisation.docker.storageDriver = "btrfs";
  zramSwap.enable = true;
  zramSwap.memoryPercent = 30;
  services.xserver.videoDrivers = [ "amdgpu" ];
  services.openssh.enable=true;
  hardware.cpu.amd.updateMicrocode = true;
  hardware.enableRedistributableFirmware = true;
  hardware.opengl.enable = true;
  hardware.opengl.driSupport = true;   
  hardware.pulseaudio = {
    enable = true;
    # Full build needed for bluetooth support
    package = pkgs.pulseaudioFull;
  };
  hardware.bluetooth.enable = true;
  hardware.sensor.iio.enable = true;
  services.upower.enable = true;

  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="backlight", RUN+="${pkgs.coreutils}/bin/chgrp video %S%p/brightness", RUN+="${pkgs.coreutils}/bin/chmod g+w %S%p/brightness"
  '';

  services.udev.path = [
   pkgs.coreutils # for chgrp
  ];

  fileSystems."/tmp" = {
    fsType = "tmpfs";
    device = "tmpfs";
    options = [ "nosuid" "nodev" "relatime" "size=5G" ];
  };

  fileSystems."/" =
    { device = "/dev/disk/by-label/nixos";
      fsType = "btrfs";
    };

  fileSystems."/d" =
    { device = "/dev/disk/by-label/data";
      fsType = "btrfs";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-label/boot";
      fsType = "vfat";
    };

  swapDevices = [ ];

  nix.maxJobs = lib.mkDefault 8;

  powerManagement.enable = true;
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
      # assuming /boot is the mount point of the  EFI partition in NixOS (as the installation section recommends).
      efiSysMountPoint = "/boot";
    };
    grub = {
      # despite what the configuration.nix manpage seems to indicate,
      # as of release 17.09, setting device to "nodev" will still call
      # `grub-install` if efiSupport is true
      # (the devices list is not used by the EFI grub install,
      # but must be set to some value in order to pass an assert in grub.nix)
      devices = [ "nodev" ];
      efiSupport = true;
      enable = true;
      # set $FS_UUID to the UUID of the EFI partition
      extraEntries = ''
        menuentry "Windows" {
          insmod part_gpt
          insmod fat
          insmod search_fs_uuid
          insmod chain
          search --fs--uid --set=root $FS_UUID
          chainloader /EFI/Microsoft/Boot/bootmgfw.efi
        }
      '';
      version = 2;
    };
  };
}
