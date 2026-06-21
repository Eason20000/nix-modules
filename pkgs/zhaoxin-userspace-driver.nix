{
  debSrc,
  lib,
  stdenv,
  dpkg,
  autoPatchelfHook,
  libdrm,
  mesa,
  libx11,
  libxrandr,
  libxcb,
  libxext,
  libxrender,
  libudev-zero,
}:

let
  version = "21.00.73";
in
stdenv.mkDerivation {
  pname = "zhaoxin-userspace-driver";
  inherit version;

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
  ];
  buildInputs = [
    libdrm
    mesa
    libx11
    libxrandr
    libxcb
    libxext
    libxrender
    libudev-zero
  ];

  dontBuild = true;
  dontStrip = true;
  dontPatchELF = true;

  # autoPatchelf needs to resolve internal deps (libkeinterface_zx.so)
  # that live in $out/lib, not in any buildInput.
  preFixup = ''
    addAutoPatchelfSearchPath "$out/lib"
  '';

  unpackPhase = ''
    dpkg -x ${debSrc} .
  '';

  installPhase = ''
    mkdir -p $out/lib
    # Only libkeinterface_zx — the kernel interface used by DRI drivers.
    base=libkeinterface_zx.so.0.0.0
    cp -v usr/lib/x86_64-linux-gnu/$base $out/lib/
    soname=libkeinterface_zx.so.0
    linker=libkeinterface_zx.so
    ln -sfn "$base" "$out/lib/$soname"
    ln -sfn "$base" "$out/lib/$linker"

    mkdir -p $out/lib/dri
    cp -v usr/lib/x86_64-linux-gnu/dri/zx_vndri.so     $out/lib/dri/zx_dri.so
    cp -v usr/lib/x86_64-linux-gnu/dri/zx_drv_video.so $out/lib/dri/
    cp -v usr/lib/x86_64-linux-gnu/dri/ZXEApp.cfg       $out/lib/dri/

    mkdir -p $out/lib/gbm
    cp -v usr/lib/x86_64-linux-gnu/gbm/zx_gbm.so $out/lib/gbm/

    mkdir -p $out/lib/vdpau
    cp -v usr/lib/x86_64-linux-gnu/libvdpau_zx.so $out/lib/vdpau/

    mkdir -p $out/lib/xorg/modules/drivers
    cp -v usr/lib/xorg/modules/drivers/zx_drv.so $out/lib/xorg/modules/drivers/

    mkdir -p $out/lib/xorg/modules/extensions
    cp -v usr/lib/xorg/modules/extensions/libglx_zx.so $out/lib/xorg/modules/extensions/

    mkdir -p $out/share/X11/xorg.conf.d
    cp -v usr/share/X11/xorg.conf.d/10-zxgpu.conf $out/share/X11/xorg.conf.d/
    sed -i '/MatchDriver "zx"/a\    Option      "GlxVendorLibrary" "zx"' \
      $out/share/X11/xorg.conf.d/10-zxgpu.conf

    mkdir -p $out/share/drirc.d
    cp -v usr/share/drirc.d/01-zx_drv.conf $out/share/drirc.d/

    runHook postInstall
  '';

  meta = {
    maintainers = with lib.maintainers; [ ];
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
    description = "Zhaoxin KX-6000 Userspace Graphics Driver (version ${version})";
    homepage = "https://www.zhaoxin.com/";
    longDescription = ''
      Userspace components for Zhaoxin KX-6000 integrated graphics:
      Gallium DRI driver (zx_dri.so), kernel interface library
      (libkeinterface_zx.so), GBM/VDPAU backends, and the Xorg DDX
      driver (zx_drv.so) with GLX extension (libglx_zx.so).  Does
      NOT include Zhaoxin's EGL/GLX vendor libs or glapi fork —
      Mesa's own GL dispatch loads the DRI driver directly, avoiding
      the glapi symbol conflict.
    '';
  };
}
