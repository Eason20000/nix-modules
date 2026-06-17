{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.my.nixos.staticIpv4;

in
{
  options.my.nixos.staticIpv4 = {
    enable = lib.mkEnableOption "";
    interface = lib.mkOption {
      type = lib.types.str;
      example = "eno1";
    };
    address = lib.mkOption {
      type = lib.types.str;
      example = "192.168.1.2/24";
    };
    gateway = lib.mkOption {
      type = lib.types.str;
      example = "192.168.1.1";
    };
  };

  config = lib.mkIf cfg.enable {
    networking.networkmanager.ensureProfiles.profiles.static-ipv4 = {
      connection = {
        id = "static-ipv4";
        interface-name = cfg.interface;
        type = "ethernet";
        autoconnect = true;
      };
      ipv4 = {
        method = "manual";
        addresses = cfg.address;
        gateway = cfg.gateway;
        dns = cfg.gateway;
      };
    };

  };

}
