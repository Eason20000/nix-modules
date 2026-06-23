{
  config,
  lib,
  pkgs,
  inputs,
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
      localPort = lib.mkOption { type = lib.types.port; };
      remotePort = lib.mkOption { type = lib.types.port; };
      proxyUser = lib.mkOption {
        type = lib.types.str;
        default = "ssh-tunnel";
      };
      identityFile = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
      };
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

    (lib.mkIf (cfg.reverseProxy.enable && cfg.reverseProxy.identityFile == null) {
      assertions = [
        {
          assertion = false;
          message = "my.nixos.ssh.reverseProxy.identityFile must be set when enable = true";
        }
      ];
    })

    (lib.mkIf cfg.reverseProxy.enable {
      services.autossh.sessions = [
        {
          name = "reverse-ssh";
          user = "reverse-tunnel";
          monitoringPort = 20000;
          extraArguments =
            let
              opts = [
                "-N"
                "-R"
                "${toString cfg.reverseProxy.remotePort}:localhost:${toString cfg.reverseProxy.localPort}"
                "-p"
                "${toString cfg.reverseProxy.proxyPort}"
                "${cfg.reverseProxy.proxyUser}@${cfg.reverseProxy.proxyHost}"
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
              ];
            in
            lib.concatStringsSep " " (
              opts
              ++ lib.optional (
                cfg.reverseProxy.identityFile != null
              ) "-i ${cfg.reverseProxy.identityFile}"
            );
        }
      ];

      users.groups.reverse-tunnel = { };
      users.users.reverse-tunnel = {
        group = "reverse-tunnel";
        isSystemUser = true;
        useDefaultShell = true;
      };

      systemd.services.autossh-reverse-ssh.serviceConfig = {
        Restart = lib.mkForce "always";
        RestartSec = 5;
      };
    })
  ];

}
