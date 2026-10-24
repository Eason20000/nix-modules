{
  config,
  lib,
  pkgs,
  my,
  osConfig,
  inputs,
  ...
}:

let
  cfg = config.my.home.ssh;
  currentHost = osConfig.networking.hostName;
  blocks =
    let
      attrSets = my.lib.queryHosts inputs {
        pred =
          h: h.config.my.nixos.base.publicHost or null != null && h.config.networking.hostName != currentHost;
        map =
          name: h:
          let
            r = h.config.my.nixos;
            base = {
              hostname = r.base.publicHost or name;
              port = lib.head (r.ssh.ports or [ 22 ]);
              user = osConfig.my.nixos.base.primaryUser or null;
            };
          in
          {
            "${name}" = base;
          }
          // lib.optionalAttrs (r.remoteDiskUnlock.enable or false) {
            "${name}.rdu" = base // {
              port = r.remoteDiskUnlock.port;
              user = "root";
            };
          };
      };
    in
    lib.foldl' (a: b: a // b) { } attrSets;

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
