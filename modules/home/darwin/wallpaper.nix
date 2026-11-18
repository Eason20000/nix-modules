{
  lib,
  pkgs,
  my,
  osConfig,
  ...
}:

{
  home.file = lib.mkIf (my.lib.darwinOn osConfig "desktop") {
    "Pictures/wallpaper".source = import ../wallpaper.nix { inherit pkgs; };
  };

}
