{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.my.nixos.waydroid;

in
{
  options.my.nixos.waydroid = {
    enable = lib.mkEnableOption "";
  };

  config = lib.mkIf cfg.enable {
    virtualisation.waydroid.enable = true;

    environment.systemPackages = with pkgs; [
      wl-clipboard
      waydroid-helper
    ];

    my.nixos.impermanence.extraDirectories = [ "/var/lib/waydroid" ];

  };

}
