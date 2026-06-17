{ config, lib, pkgs, my, osConfig, inputs, ... }:

let
  cfg = config.my.home.ssh;
  allConfigs = inputs.self.nixosConfigurations or { };
  currentHost = osConfig.networking.hostName;

  # Only hosts with publicHost set are reachable remotely
  remoteConfigs = lib.filterAttrs (name: hostCfg:
    name != currentHost &&
    hostCfg.config.my.nixos.base.publicHost or null != null
  ) allConfigs;

  # Build SSH settings for each remote host
  blocks = builtins.listToAttrs (lib.concatMap (name:
    let
      h = allConfigs.${name}.config.my.nixos;
      host = h.base.publicHost or name;
      port = lib.head (h.ssh.ports or [ 22 ]);
      base = { hostname = host; user = osConfig.my.nixos.base.primaryUser or null; };
      rdu = h.remoteDiskUnlock;
    in
    [
      { name = name; value = base // { inherit port; }; }
    ]
    ++ lib.optionals (rdu.enable or false) [
      { name = "${name}_rdu"; value = base // { port = rdu.port; user = "root"; }; }
    ]
  ) (builtins.attrNames remoteConfigs));

in
{
  options.my.home.ssh = {
    enable = lib.mkEnableOption "" // {
      default = my.lib.on osConfig "ssh";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.ssh.enable = true;
    programs.ssh.settings = blocks;
  };

}
