{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.my.nixos.ssh;

in
{
  options.my.nixos.ssh = {
    enable = lib.mkEnableOption "" // {
      default = true;
    };
    ports = lib.mkOption {
      type = lib.types.listOf lib.types.port;
      default = [ 22 ];
    };
    tunnel = {
      enable = lib.mkEnableOption "";
      authorizedKeys = lib.mkOption { type = lib.types.listOf lib.types.str; };
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      services.openssh = {
        enable = true;
        ports = cfg.ports;
        settings = {
          PasswordAuthentication = false;
          X11Forwarding = true;
          GatewayPorts = "clientspecified";
        };
      };

    })

    (lib.mkIf (cfg.enable && cfg.tunnel.enable) {
      users.groups.ssh-tunnel = { };
      users.users.ssh-tunnel = {
        group = "ssh-tunnel";
        isSystemUser = true;
        shell = "${pkgs.shadow}/bin/nologin";
        createHome = false;
        openssh.authorizedKeys.keys = cfg.tunnel.authorizedKeys;
      };

    })
  ];

}
