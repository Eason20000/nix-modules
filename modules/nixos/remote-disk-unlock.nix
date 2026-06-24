{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  cfg = config.my.nixos.remoteDiskUnlock;

in
{
  options.my.nixos.remoteDiskUnlock = {
    enable = lib.mkEnableOption "";
    hostKeys = lib.mkOption {
      type = lib.types.listOf lib.types.path;
      default = [ ];
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 2222;
    };
    interface = lib.mkOption {
      type = lib.types.str;
      default = config.my.nixos.staticIpv4.interface or "en*";
      example = "eno1";
    };
    staticIp = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = config.my.nixos.staticIpv4.address or null;
      example = "192.168.1.2/24";
    };
    gateway = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = config.my.nixos.staticIpv4.gateway or null;
      example = "192.168.1.1";
    };
    dns = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = config.my.nixos.staticIpv4.dns or null;
      example = "192.168.1.1";
    };
    reverseProxy = {
      enable = lib.mkEnableOption "";
      proxyHost = lib.mkOption {
        type = lib.types.str;
        default =
          let
            all = inputs.self.nixosConfigurations or { };
            hosts = builtins.attrNames all;
            hasTunnel = name: all.${name}.config.my.nixos.ssh.tunnel.enable or false;
            tunnelHost = lib.findFirst hasTunnel null hosts;
          in
          if tunnelHost != null then
            all.${tunnelHost}.config.my.nixos.base.publicHost or tunnelHost
          else
            "";
      };
      proxyPort = lib.mkOption {
        type = lib.types.port;
        default =
          let
            all = inputs.self.nixosConfigurations or { };
            hosts = builtins.attrNames all;
            hasTunnel = name: all.${name}.config.my.nixos.ssh.tunnel.enable or false;
            tunnelHost = lib.findFirst hasTunnel null hosts;
          in
          if tunnelHost != null then
            lib.head (all.${tunnelHost}.config.my.nixos.ssh.ports or [ 22 ])
          else
            22;
      };
      proxyUser = lib.mkOption {
        type = lib.types.str;
        default = "ssh-tunnel";
      };
    };
    tunnelKeyFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      boot.initrd.systemd.network = {
        enable = true;
        networks."10-wired" = {
          matchConfig.Name = cfg.interface;
          networkConfig = lib.mkMerge [
            (lib.mkIf (cfg.staticIp == null) { DHCP = "yes"; })
            (lib.mkIf (cfg.staticIp != null) {
              Address = cfg.staticIp;
              Gateway = cfg.gateway;
              DNS = cfg.dns;
            })
          ];
        };
      };

      boot.initrd.network.ssh = {
        enable = true;
        port = cfg.port;
        authorizedKeys =
          lib.map (key: ''command="systemctl default" '' + key)
            config.users.users.${config.my.nixos.base.primaryUser}.openssh.authorizedKeys.keys;
        hostKeys = cfg.hostKeys;
      };

    })

    (lib.mkIf (cfg.enable && cfg.reverseProxy.enable && cfg.tunnelKeyFile == null) {
      assertions = [
        {
          assertion = false;
          message = "my.nixos.remoteDiskUnlock.tunnelKeyFile must be set when reverseProxy.enable = true";
        }
      ];
    })

    (lib.mkIf (cfg.enable && cfg.reverseProxy.enable && cfg.tunnelKeyFile != null) {
      boot.initrd.secrets."/etc/secrets/tunnel-key" = cfg.tunnelKeyFile;

      boot.initrd.systemd.storePaths = [
        "${pkgs.openssh}/bin/ssh"
        "${pkgs.autossh}/bin/autossh"
        "${pkgs.coreutils}/bin/chmod"
      ];

      boot.initrd.systemd.services.reverse-tunnel = {
        description = "SSH Reverse Tunnel for RDU";
        wantedBy = [ "initrd.target" ];
        after = [ "network.target" ];
        before = [ "sshd.service" ];
        unitConfig.DefaultDependencies = false;
        serviceConfig = {
          Type = "simple";
          ExecStartPre = "${pkgs.coreutils}/bin/chmod 0600 /etc/secrets/tunnel-key";
          ExecStart = lib.concatStringsSep " " (
            [
              "${pkgs.autossh}/bin/autossh"
              "-M"
              "0"
            ]
            ++ [
              "-N"
              "-R"
              "${toString cfg.port}:localhost:${toString cfg.port}"
              "-p"
              "${toString cfg.reverseProxy.proxyPort}"
              "${cfg.reverseProxy.proxyUser}@${cfg.reverseProxy.proxyHost}"
              "-i"
              "/etc/secrets/tunnel-key"
              "-o"
              "StrictHostKeyChecking=no"
              "-o"
              "UserKnownHostsFile=/dev/null"
              "-o"
              "ServerAliveInterval=30"
              "-o"
              "ServerAliveCountMax=3"
              "-o"
              "ExitOnForwardFailure=yes"
              "-o"
              "TCPKeepAlive=yes"
              "-o"
              "ConnectTimeout=10"
            ]
          );
          Restart = "always";
          RestartSec = 5;
        };
      };
    })
  ];

}
