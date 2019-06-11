{ config, lib, pkgs, ... }:

let
 piensa = import (builtins.fetchTarball https://github.com/piensa/nur-packages/archive/master.tar.gz) {};
in rec {
  environment.systemPackages = with pkgs; [
    piensa.reva
    piensa.imposm
  ];
}
