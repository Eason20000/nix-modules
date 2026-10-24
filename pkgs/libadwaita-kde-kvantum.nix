{
  lib,
  stdenv,
  fetchFromGitHub,
  bash,
}:

stdenv.mkDerivation {
  pname = "libadwaita-kde-kvantum";
  version = "unstable-2025-03-09";

  src = fetchFromGitHub {
    owner = "Neikon";
    repo = "Libadwaita-KDE";
    rev = "d606756056e2bd15a24d0a61020fcfc5ca72e30b";
    sha256 = "sha256-xjvIvHX+DsyV/JiBlYaamQMHhyNdoVS2xsPQyG8l/yc=";
  };

  nativeBuildInputs = [ bash ];

  dontConfigure = true;
  dontFixup = true;

  buildPhase = ''
    cd Kvantum
    for mode in dark light; do
      for accent in blue teal green yellow orange red pink purple slate; do
        bash ./build.sh "$mode" "$accent"
      done
    done
  '';

  installPhase = ''
    mkdir -p $out/share/Kvantum
    cp -r libadwaita-kde-* $out/share/Kvantum/
  '';

  meta = with lib; {
    description = "Libadwaita-KDE Kvantum theme";
    homepage = "https://github.com/Neikon/Libadwaita-KDE";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
  };

}
