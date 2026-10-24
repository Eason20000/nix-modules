{
  lib,
  pkgs,
  my,
  osConfig,
  ...
}:

{
  home.file = lib.mkIf (my.lib.darwinOn osConfig "desktop") {
    "Pictures/wallpaper".source = pkgs.fetchurl {
      url = "https://i.pximg.net/img-original/img/2020/08/31/22/44/30/84070482_p0.jpg";
      curlOpts = "--referer https://www.pixiv.net/";
      hash = "sha256-Gr5vdddBZX9qUDcZcpchCFjJ69ZR/Au61qeYSrHbUB0=";
    };
  };

}
