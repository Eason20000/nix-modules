{
  config,
  lib,
  pkgs,
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
  };

  config = lib.mkIf cfg.enable {
    boot.initrd.systemd.network = {
      enable = true;
      networks."10-wired" = {
        matchConfig.Name = cfg.interface;
        networkConfig = lib.mkMerge [
          (lib.mkIf (cfg.staticIp == null) { DHCP = "yes"; })
          (lib.mkIf (cfg.staticIp != null) {
            Address = cfg.staticIp;
            Gateway = cfg.gateway;
            DNS = cfg.gateway;
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

  };

}
