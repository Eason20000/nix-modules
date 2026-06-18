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
    useDerivation = lib.mkEnableOption "";
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
    reverseProxy = {
      enable = lib.mkEnableOption "";
      proxyHost = lib.mkOption {
        type = lib.types.str;
        default = let
          all = inputs.self.nixosConfigurations or { };
          hosts = builtins.attrNames all;
          hasTunnel = name: all.${name}.config.my.nixos.ssh.tunnel.enable or false;
          tunnelHost = lib.findFirst hasTunnel null hosts;
        in
          if tunnelHost != null
          then "${all.${tunnelHost}.config.my.nixos.base.publicHost or tunnelHost}:${toString (lib.head (all.${tunnelHost}.config.my.nixos.ssh.ports or [ 22 ]))}"
          else "";
      };
      proxyUser = lib.mkOption { type = lib.types.str; default = "ssh-tunnel"; };
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
              DNS = config.my.nixos.staticIpv4.dns or cfg.gateway;
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
        hostKeys =
          if cfg.useDerivation then
            let
              ed25519Key = pkgs.runCommand "initrd-ssh-host-ed25519" { }
                "${pkgs.openssh}/bin/ssh-keygen -t ed25519 -N \"\" -f $out";
              rsaKey = pkgs.runCommand "initrd-ssh-host-rsa" { }
                "${pkgs.openssh}/bin/ssh-keygen -t rsa -N \"\" -f $out";
            in
            [
              (builtins.unsafeDiscardStringContext ed25519Key.outPath)
              (builtins.unsafeDiscardStringContext rsaKey.outPath)
            ]
          else [
            "/etc/secrets/initrd/ssh_host_rsa_key"
            "/etc/secrets/initrd/ssh_host_ed25519_key"
          ];
      };

    })

    (lib.mkIf (cfg.enable && cfg.reverseProxy.enable) {
      sops.templates."tunnel-key-persist" = {
        path = "/nix/persist/nixos/etc/secrets/tunnel-key";
        content = config.sops.placeholder.tunnel-key;
        mode = "0400";
      };

      boot.initrd.secrets."/etc/secrets/tunnel-key" =
        "/nix/persist/nixos/etc/secrets/tunnel-key";

      boot.initrd.systemd.storePaths = [ "${pkgs.openssh}/bin/ssh" ];

      boot.initrd.systemd.services.reverse-tunnel = {
        description = "SSH Reverse Tunnel for RDU";
        wantedBy = [ "initrd.target" ];
        after = [ "network.target" ];
        before = [ "sshd.service" ];
        unitConfig.DefaultDependencies = false;
        serviceConfig = {
          Type = "simple";
          ExecStart = lib.concatStringsSep " " [
            "${pkgs.openssh}/bin/ssh"
            "-N"
            "-R"
            "${toString cfg.port}:localhost:${toString cfg.port}"
            "${cfg.reverseProxy.proxyUser}@${cfg.reverseProxy.proxyHost}"
            "-i"
            "/etc/secrets/tunnel-key"
            "-o" "StrictHostKeyChecking=no"
            "-o" "UserKnownHostsFile=/dev/null"
            "-o" "ServerAliveInterval=30"
            "-o" "ServerAliveCountMax=3"
            "-o" "ExitOnForwardFailure=yes"
            "-o" "TCPKeepAlive=yes"
            "-o" "ConnectTimeout=10"
          ];
          Restart = "always";
          RestartSec = 5;
        };
      };
    })
  ];

}
