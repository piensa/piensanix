{ config, lib, pkgs, ... }:

let
 piensa = import (builtins.fetchTarball https://github.com/piensa/nur-packages/archive/master.tar.gz) {};
  revad-config = pkgs.writeText "revad.toml" ''
[core]
log_file = "stderr"
log_mode = "dev"
max_cpus = "100%"

[log]
level = "debug"
mode = "console"

[http]
enabled_services = ["prometheussvc", "ocdavsvc", "datasvc","preferencessvc"]
enabled_middlewares = ["cors", "log", "auth"]
network = "tcp"
address = "0.0.0.0:9998"


[http.middlewares.log]
priority = 200

[http.middlewares.auth]
priority = 300
authsvc = "0.0.0.0:9999"
credential_strategy = "basic"
token_strategy = "header"
token_writer = "header"
token_manager = "jwt"
skip_methods = ["/owncloud/status.php", "/metrics"]

[http.middlewares.auth.token_managers.jwt]
secret = "Pive-Fumkiu4"

[http.middlewares.auth.token_strategies.header]
header = "X-Access-Token"

[http.middlewares.auth.token_writers.header]
header = "X-Access-Token"

[http.middlewares.cors]
priority = 400

[http.services.preferencessvc]
prefix = "preferences"
preferencessvc = "localhost:9999"

[http.services.prometheussvc]
prefix = "metrics"

[http.services.iframeuisvc]
prefix = "iframe"

[http.services.webuisvc]
prefix = "ui"

[http.services.ocdavsvc]
prefix = "owncloud"
chunk_folder = "/var/tmp/owncloud/chunks"
storageprovidersvc = "localhost:9999"
enable_cors = true

[http.services.datasvc]
driver = "local"
prefix = "data"
temp_folder = "/var/tmp/"

[http.services.datasvc.drivers.eos]
mgm = "root://nowhere.org"
root_uid = 0
root_gid = 0

[http.services.datasvc.drivers.local]
root = "/var/tmp/owncloud/data"

[grpc]
network = "tcp"
address = "0.0.0.0:9999"
access_log = "stderr"
tls_enabled = true
tls_cert = "/etc/gridsecurity/host.cert"
tls_key = "/etc/gridsecurity/host.key"
enabled_services = ["storageprovidersvc", "authsvc", "storageregistrysvc", "appregistrysvc", "appprovidersvc", "preferencessvc"]
enabled_interceptors = ["auth", "prometheus", "log"]

[grpc.interceptors.recovery]
priority = 100

[grpc.interceptors.log]
priority = 200

[grpc.interceptors.prometheus]
priority = 300

[grpc.interceptors.auth]
priority = 400
header = "x-access-token"
token_manager = "jwt"
skip_methods = ["/cs3.authv0alpha.AuthService/GenerateAccessToken"]

[grpc.interceptors.auth.token_managers.jwt]
secret = "Pive-Fumkiu4"

[grpc.services.storageprovidersvc]
driver = "local"
mount_path = "/"
mount_id = "123e4567-e89b-12d3-a456-426655440000"
data_server_url = "http://localhost:9998/data"
[grpc.services.storageprovidersvc.available_checksums]
md5   = 100
unset = 1000

[grpc.services.storageprovidersvc.drivers.eos]
mgm = "root://nowhere.org"
root_uid = 0
root_gid = 0

[grpc.services.storageprovidersvc.drivers.local]
root = "/var/tmp/owncloud/data"

[grpc.services.authsvc]
auth_manager = "demo"
token_manager = "jwt"
user_manager = "demo"

[grpc.services.authsvc.token_managers.jwt]
secret = "Pive-Fumkiu4"

[grpc.services.storageregistrysvc]
driver = "static"

[grpc.services.storageregistrysvc.drivers.static.rules]
"/" = "localhost:9999"
"123e4567-e89b-12d3-a456-426655440000" = "localhost:9999"

[grpc.services.appregistrysvc]
driver = "static"

[grpc.services.appregistrysvc.static.rules]
".txt" = "localhost:9999"
"txt/plain" = "localhost:9999"

[grpc.services.appprovidersvc]
driver = "demo"

[grpc.services.appprovidersvc.demo]
iframe_ui_provider = "http://localhost:9998/iframeuisvc"
'';
in rec {
  environment.systemPackages = with pkgs; [
    piensa.reva
    piensa.dbxcli
    owncloud-client
  ];

  systemd.services.revad = {
   description = "revad";
   serviceConfig = {
     LimitNOFILE=65536;
     PermissionsStartOnly=true;
     Type="simple";
     ExecStart = "${piensa.reva}/bin/revad -c ${revad-config} -p /tmp/revad.pid";
     ExecStop = "/run/current-system/sw/bin/pkill revad";
     Restart = "on-failure";
     User = "x";
   };
   wantedBy = [ "default.target" ];
 };

}
