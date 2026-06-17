{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.my.nixos.desktop;

in
{
  options.my.nixos.desktop = {
    enable = lib.mkEnableOption "";
  };

  config = lib.mkIf cfg.enable {
    services = {
      desktopManager.plasma6.enable = true;
      displayManager.plasma-login-manager.enable = true;
    };

    boot = {
      kernelParams = [
        "quiet"
        "rd.udev.log_level=3"
        "rd.systemd.show_status=auto"
      ];
      consoleLogLevel = 3;
      initrd.verbose = false;
      plymouth.enable = true;
      loader.timeout = 0;
    };

    services.ratbagd.enable = true;
    services.flatpak.enable = true;
    services.printing = {
      enable = true;
      drivers = with pkgs; [
        gutenprint
        hplipWithPlugin
        splix
      ];
    };

    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };

    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings = {
        General = {
          Experimental = true;
          FastConnectable = true;
        };
      };
    };

    fonts = {
      fontDir.enable = true;
      enableDefaultPackages = true;
      packages = with pkgs; [
        corefonts
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-cjk-serif
        noto-fonts-color-emoji
        hack-font
      ];
      fontconfig = {
        defaultFonts = {
          sansSerif = [
            "Noto Sans"
            "Noto Sans CJK SC"
          ];
          serif = [
            "Noto Serif"
            "Noto Serif CJK SC"
          ];
          monospace = [
            "Hack"
            "Noto Sans Mono CJK SC"
          ];
        };
      };
    };

    i18n.inputMethod = {
      enable = true;
      type = "fcitx5";
      fcitx5 = {
        waylandFrontend = true;
        addons = with pkgs; [
          kdePackages.fcitx5-chinese-addons
          fcitx5-pinyin-zhwiki
          fcitx5-pinyin-moegirl
          fcitx5-pinyin-minecraft
        ];
      };
    };

  };

}
