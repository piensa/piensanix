{ config, lib, pkgs, ... }:

{
  imports =
    [ <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
     ./host.nix
     ./user.nix
     ./i3.nix
     ./sway.nix
     ./piensa.nix
     #./kube.nix
    ];

  system.stateVersion = "19.03";

}
