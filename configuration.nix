{ config, lib, pkgs, ... }:

{
  imports =
    [ <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
     ./host.nix
     ./user.nix
     ./i3.nix
     ./sway.nix
     ./kube.nix
    ];

  system.stateVersion = "unstable";

}
