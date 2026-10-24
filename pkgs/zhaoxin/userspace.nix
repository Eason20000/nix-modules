{
  debSrc,
  lib,
  stdenv,
  dpkg,
  autoPatchelfHook,
  libdrm,
  libx11,
  libxrandr,
  libxcb,
}:

let
  version = "21.00.91";
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
    libx11
    libxrandr
    libxcb
    stdenv.cc.cc.lib
  ];

  dontBuild = true;
  dontStrip = true;

  # autoPatchelf needs to resolve internal deps (libkeinterface_zx.so)
  # that live in $out/lib, not in any buildInput.
  preFixup = ''
    addAutoPatchelfSearchPath "$out/lib"
  '';

  unpackPhase = ''
    dpkg -x ${debSrc} .
  '';

  installPhase = ''
    # Only the VA-API backend is worth keeping. The vendor GL stack
    # (EGL/GLX ICDs, GBM backend, Xorg DDX) is closed-source, GLES2-only
    # and ABI-incompatible with current Mesa/Xorg, and breaks modern
    # compositors. 3D rendering stays on Mesa llvmpipe.
    mkdir -p $out/lib/dri
    cp -v usr/lib/x86_64-linux-gnu/dri/zx_drv_video.so $out/lib/dri/
    cp -v usr/lib/x86_64-linux-gnu/dri/ZXEApp.cfg $out/lib/dri/

    # Internal helper required by zx_drv_video.so. Plain library, not
    # auto-discovered by any loader, so harmless to ship.
    mkdir -p $out/lib
    cp -v usr/lib/x86_64-linux-gnu/libkeinterface_zx.so.0.0.0 $out/lib/
    ln -sfn libkeinterface_zx.so.0.0.0 $out/lib/libkeinterface_zx.so.0

    mkdir -p $out/share/drirc.d
    cp -v usr/share/drirc.d/01-zx_drv.conf $out/share/drirc.d/

    runHook postInstall
  '';

  meta = {
    maintainers = with lib.maintainers; [ ];
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
    description = "Zhaoxin KX-6000 VA-API video driver (version ${version})";
    homepage = "https://www.zhaoxin.com/";
    longDescription = ''
      VA-API backend (zx_drv_video.so) for Zhaoxin KX-6000 integrated
      graphics: hardware video decode/encode. The vendor GL stack is
      intentionally not shipped, see installPhase.
    '';
  };
}
