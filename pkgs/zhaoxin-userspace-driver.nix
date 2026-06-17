{
  debSrc,
  lib,
  stdenv,
  dpkg,
  autoPatchelfHook,
  libdrm,
  mesa,
  wayland,
  libglvnd,
  libx11,
  libxext,
  libxfixes,
  libxdamage,
  libxxf86vm,
  libxrandr,
  libxrender,
  libxcb,
  libxshmfence,
  expat,
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
    wayland
    libglvnd
    libx11
    libxext
    libxfixes
    libxdamage
    libxxf86vm
    libxrandr
    libxrender
    libxcb
    libxshmfence
    expat
  ];

  dontBuild = true;
  dontStrip = true;

  # autoPatchelf needs to resolve internal deps (e.g. libglapi_zx.so.0)
  # that live in $out/lib, not in any buildInput.
  preFixup = ''
    addAutoPatchelfSearchPath "$out/lib"
  '';

  unpackPhase = ''
    dpkg -x ${debSrc} .
  '';

  installPhase = ''
    mkdir -p $out/lib
    for libfile in usr/lib/x86_64-linux-gnu/libEGL_zx.so.0.0.0 \
                   usr/lib/x86_64-linux-gnu/libGLX_zx.so.0.0.0 \
                   usr/lib/x86_64-linux-gnu/libglapi_zx.so.0.0.0 \
                   usr/lib/x86_64-linux-gnu/libkeinterface_zx.so.0.0.0; do
      base=''${libfile##*/}
      cp -v "$libfile" $out/lib/
      soname=''${base%.0.0}
      linker=''${base%.so*}.so
      ln -sfn "$base" "$out/lib/$soname"
      ln -sfn "$base" "$out/lib/$linker"
    done

    mkdir -p $out/lib/vdpau
    cp -v usr/lib/x86_64-linux-gnu/libvdpau_zx.so $out/lib/vdpau/

    mkdir -p $out/lib/gbm
    cp -v usr/lib/x86_64-linux-gnu/gbm/zx_gbm.so $out/lib/gbm/

    mkdir -p $out/lib/dri
    cp -v usr/lib/x86_64-linux-gnu/dri/zx_drv_video.so $out/lib/dri/
    cp -v usr/lib/x86_64-linux-gnu/dri/zx_vndri.so     $out/lib/dri/
    cp -v usr/lib/x86_64-linux-gnu/dri/ZXEApp.cfg       $out/lib/dri/

    mkdir -p $out/lib/xorg/modules/drivers
    cp -v usr/lib/xorg/modules/drivers/zx_drv.so $out/lib/xorg/modules/drivers/

    mkdir -p $out/lib/xorg/modules/extensions
    cp -v usr/lib/xorg/modules/extensions/libglx_zx.so $out/lib/xorg/modules/extensions/

    mkdir -p $out/share/glvnd/egl_vendor.d
    cp -v usr/share/glvnd/egl_vendor.d/10_zx.json $out/share/glvnd/egl_vendor.d/
    substituteInPlace $out/share/glvnd/egl_vendor.d/10_zx.json \
      --replace '"library_path" : ""' '"library_path" : "'$out'/lib/libEGL_zx.so.0"'

    mkdir -p $out/share/drirc.d
    cp -v usr/share/drirc.d/01-zx_drv.conf $out/share/drirc.d/

    mkdir -p $out/share/X11/xorg.conf.d
    cp -v usr/share/X11/xorg.conf.d/10-zxgpu.conf $out/share/X11/xorg.conf.d/
    sed -i '/MatchDriver "zx"/a\    Option      "GlxVendorLibrary" "zx"' \
      $out/share/X11/xorg.conf.d/10-zxgpu.conf

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
      EGL, GLX, VDPAU, GBM, DRI, Xorg DDX driver, and GLVND vendor
      configuration.
    '';
  };
}
