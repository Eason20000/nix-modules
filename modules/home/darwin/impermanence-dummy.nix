{
  lib,
  my,
  osConfig,
  ...
}:

{
  options.my.home.impermanence = {
    enable = lib.mkEnableOption "" // {
      default = my.lib.on osConfig "impermanence";
    };
    extraDirectories = lib.mkOption {
      type = lib.types.listOf (lib.types.either lib.types.str lib.types.attrs);
      default = [ ];
    };
    extraFiles = lib.mkOption {
      type = lib.types.listOf (lib.types.either lib.types.str lib.types.attrs);
      default = [ ];
    };
  };

}
