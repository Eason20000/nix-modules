{
  lib,
  my,
  osConfig,
  ...
}:

{
  imports = [
    ./base.nix
    ./impermanence-dummy.nix
    ./wallpaper.nix
  ]
  ++ lib.optionals (my.lib.darwinOn osConfig "desktop") [ ./desktop-packages.nix ];
}
