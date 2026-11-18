# Shared desktop wallpaper, used by the NixOS GNOME session and the Darwin
# desktop. Kept as a plain function (not a module) so both platforms hold the
# same URL/hash and only differ in where the file is installed.
{ pkgs }:

pkgs.fetchurl {
  url = "https://i.pximg.net/img-original/img/2020/08/31/22/44/30/84070482_p0.jpg";
  curlOpts = "--referer https://www.pixiv.net/";
  hash = "sha256-Gr5vdddBZX9qUDcZcpchCFjJ69ZR/Au61qeYSrHbUB0=";
}
