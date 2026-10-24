{ config, lib, ... }:

let
  cfg = config.my.nixos.data;

in
{
  options.my.nixos.data = {
    enable = lib.mkEnableOption "";
    vault.enable = lib.mkEnableOption "";
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      users.groups."data" = { };
      systemd.tmpfiles.rules = [ "d /data 0770 root data -" ];
    })

    (lib.mkIf (cfg.enable && cfg.vault.enable) {
      systemd.tmpfiles.rules = [ "d /data/vault 0770 root data -" ];
    })

  ];

}
