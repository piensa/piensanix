{ config, lib, pkgs, ... }:

let
 piensa = import (builtins.fetchTarball https://github.com/piensa/nur-packages/archive/4cf31e0.tar.gz) {};
in rec {
  environment.systemPackages = with pkgs; [
    piensa.reva
    piensa.dbxcli
    owncloud-client
  ];

}
