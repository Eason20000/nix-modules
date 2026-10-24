{
  config,
  lib,
  my,
  osConfig,
  ...
}:

let
  cfg = config.my.home.data;

in
{
  options.my.home.data = {
    enable = lib.mkEnableOption "" // {
      default = my.lib.on osConfig "data";
    };
  };

  config = lib.mkIf cfg.enable {
    home.file."data".source = config.lib.file.mkOutOfStoreSymlink "/data";
  };

}
