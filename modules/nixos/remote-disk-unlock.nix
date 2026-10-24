{
  config,
  lib,
  pkgs,
  inputs,
  my,
  ...
}:

let
  cfg = config.my.nixos.remoteDiskUnlock;

  tunnelInfo = my.lib.queryHosts inputs {
    pred = h: h.config.my.nixos.ssh.tunnel.enable or false;
    map = _: h: {
      host = h.config.my.nixos.base.publicHost or h.config.networking.hostName or "";
      port = lib.head (h.config.my.nixos.ssh.ports or [ 22 ]);
    };
    first = true;
  };

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
      default = cfg.gateway;
      example = "192.168.1.1";
    };
    reverseProxy = {
      enable = lib.mkEnableOption "";
      proxyHost = lib.mkOption {
        type = lib.types.str;
        default = tunnelInfo.host or "";
      };
      proxyPort = lib.mkOption {
        type = lib.types.port;
        default = tunnelInfo.port or 22;
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
    tunnelKeyPath = lib.mkOption {
      type = lib.types.str;
      default = "/etc/tunnel-key";
      description = "Path inside the initrd where the tunnel key is mounted.";
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
        authorizedKeys = lib.map (
          key: ''command="systemctl default" '' + key
        ) config.users.users.${config.my.nixos.base.primaryUser}.openssh.authorizedKeys.keys;
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
      boot.initrd.secrets.${cfg.tunnelKeyPath} = cfg.tunnelKeyFile;

      boot.initrd.systemd.storePaths = [
        "${pkgs.openssh}/bin/ssh"
        "${pkgs.coreutils}/bin/chmod"
        "${pkgs.dnsutils}/bin/dig"
      ];

      boot.initrd.systemd.services.reverse-tunnel = {
        description = "SSH Reverse Tunnel for RDU";
        wantedBy = [ "initrd.target" ];
        after = [ "network.target" ];
        before = [ "sshd.service" ];
        unitConfig.DefaultDependencies = false;
        serviceConfig = {
          Type = "simple";
          Restart = "always";
          RestartSec = 5;
        };
        script = ''
          ${pkgs.coreutils}/bin/chmod 0600 ${cfg.tunnelKeyPath}
          IP=$(${pkgs.dnsutils}/bin/dig +short +time=5 +tries=1 A @${cfg.dns} ${cfg.reverseProxy.proxyHost} | head -1)
          [ -z "$IP" ] && { echo "DNS: empty response"; exit 1; }
          exec ${pkgs.openssh}/bin/ssh -N \
            -R 0.0.0.0:${toString cfg.port}:localhost:${toString cfg.port} \
            -p ${toString cfg.reverseProxy.proxyPort} \
            ${cfg.reverseProxy.proxyUser}@$IP \
            -i ${cfg.tunnelKeyPath} \
            -o StrictHostKeyChecking=no \
            -o UserKnownHostsFile=/dev/null \
            -o ServerAliveInterval=30 \
            -o ServerAliveCountMax=3 \
            -o ExitOnForwardFailure=yes \
            -o TCPKeepAlive=yes \
            -o ConnectTimeout=10
        '';
      };
    })
  ];

}
