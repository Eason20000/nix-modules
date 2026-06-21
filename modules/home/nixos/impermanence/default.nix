{
  config,
  lib,
  my,
  osConfig,
  ...
}:

let
  cfg = config.my.home.impermanence;

in
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

  config = lib.mkIf cfg.enable {
    home.persistence."/nix/persist" = {
      hideMounts = true;
      allowTrash = true;
      directories =
        let
          removeHomePrefix =
            directory: lib.removePrefix "${config.home.homeDirectory}/" directory;
        in
        [
          (removeHomePrefix "${config.xdg.userDirs.desktop}")
          (removeHomePrefix "${config.xdg.userDirs.documents}")
          (removeHomePrefix "${config.xdg.userDirs.download}")
          (removeHomePrefix "${config.xdg.userDirs.music}")
          (removeHomePrefix "${config.xdg.userDirs.pictures}")
          (removeHomePrefix "${config.xdg.userDirs.publicShare}")
          (removeHomePrefix "${config.xdg.userDirs.templates}")
          (removeHomePrefix "${config.xdg.userDirs.videos}")
        ]
        ++ cfg.extraDirectories;
      files = cfg.extraFiles;
    };
  };

}
