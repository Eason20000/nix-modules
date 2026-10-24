{
  pkgs,
  lib,
  inputs,
  config,
  ...
}:

let
  cfg = config.my.nixos.secureBoot;

in
{
  imports = [ inputs.lanzaboote.nixosModules.lanzaboote ];

  options.my.nixos.secureBoot = {
    enable = lib.mkEnableOption "";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.sbctl ];

    boot.loader = {
      systemd-boot = {
        enable = lib.mkForce false;
        editor = false;
      };
    };

    boot.lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
    };

    my.nixos.impermanence.extraDirectories = [ "/var/lib/sbctl" ];

  };

}
