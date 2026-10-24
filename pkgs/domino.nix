{
  stdenvNoCC,
  lib,
  mkWindowsAppNoCC,
  wineWow64Packages,
  fetchurl,
  makeDesktopItem,
  makeDesktopIcon,
  copyDesktopItems,
  copyDesktopIcons,
  unzip,
  icoutils,
  dpi ? 96,
}:

mkWindowsAppNoCC rec {

  pname = "domino";
  version = "1.45-dev009";

  src = fetchurl {
    url = "https://takabosoft.com/beta/Domino145_dev009_x64.zip";
    sha256 = "sha256-s+4vaNu83Rud/Hx1SNVqDMzqwZ1CUEcyRcoYoCCFC7A=";
  };

  dontUnpack = true;

  wine = wineWow64Packages.unstable;
  wineArch = "win64";
  enableMonoBootPrompt = false;
  enableInstallNotification = true;

  fileMap = {
    "$HOME/.config/${pname}/IniFiles" = "drive_c/${pname}/IniFiles";
    "$HOME/.config/${pname}/Module" = "drive_c/${pname}/Module";
  };
  fileMapDuringAppInstall = true;

  graphicsDriver = "prefer-wayland";

  nativeBuildInputs = [
    copyDesktopItems
    copyDesktopIcons
  ];

  winAppInstall = ''
    d="$WINEPREFIX/drive_c/${pname}"
    config_dir="$HOME/.config/${pname}"

    mkdir -p "$d"
    ${unzip}/bin/unzip -n ${src} -d "$d"

    winetricks fakejapanese_ipamona
  '';

  winAppPreRun = ''
    wine reg add 'HKEY_CURRENT_USER\Control Panel\Desktop' \
      /v LogPixels /t REG_DWORD /d ${builtins.toString dpi} /f
  '';

  winAppRun = ''
    export LANG=ja_JP.UTF-8
    wine "$WINEPREFIX/drive_c/${pname}/Domino.exe" "$ARGS"
  '';

  installPhase = ''
    runHook preInstall
    ln -s $out/bin/.launcher $out/bin/${pname}
    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = pname;
      exec = pname;
      icon = pname;
      desktopName = "Domino";
      genericName = "MIDI音楽編集ソフト";
      categories = [
        "AudioVideo"
        "Audio"
        "Midi"
        "Sequencer"
      ];
      mimeTypes = [
        "audio/midi"
        "audio/x-midi"
      ];
    })
  ];

  desktopIcon = makeDesktopIcon {
    name = pname;
    src = stdenvNoCC.mkDerivation {
      name = "${pname}.ico";
      inherit src;
      dontUnpack = true;
      nativeBuildInputs = [
        unzip
        icoutils
      ];
      installPhase = ''
        runHook preInstall

        unzip ${src} Domino.exe
        wrestool --extract Domino.exe \
          --type 14 --name 128 --output="$out"

        runHook postInstall
      '';
    };
  };

  meta = with lib; {
    description = "MIDI音楽編集ソフト";
    homepage = "https://takabosoft.com/domino";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
  };

}
