{
  config,
  lib,
  my,
  osConfig,
  ...
}:

let
  cfg = config.my.home.waydroid;

in
{
  options.my.home.waydroid = {
    enable = lib.mkEnableOption "" // {
      default = my.lib.on osConfig "waydroid";
    };
  };

  config = lib.mkIf cfg.enable {
    my.home.impermanence.extraDirectories = [ ".local/share/waydroid" ];
  };

}
