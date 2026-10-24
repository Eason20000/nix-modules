{ pkgs, ... }:

{
  home.packages = with pkgs; [
    kdePackages.qtstyleplugin-kvantum
    libsForQt5.qtstyleplugin-kvantum
  ];

  gtk = {
    enable = true;
    gtk3.theme = {
      name = "adw-gtk3-dark";
      package = pkgs.adw-gtk3;
    };
    gtk3.extraCss = ''
      @define-color accent_blue #3584e4;
      @define-color accent_teal #2190a4;
      @define-color accent_green #3a944a;
      @define-color accent_yellow #c88800;
      @define-color accent_orange #ed5b00;
      @define-color accent_red #e62d42;
      @define-color accent_pink #d56199;
      @define-color accent_purple #9141ac;
      @define-color accent_slate #6f8396;
      @define-color accent_bg_color @accent_orange;
    '';
  };

  qt = {
    enable = true;
    platformTheme.name = "qtct";
    style.name = "kvantum-dark";
  };
  xdg.configFile."Kvantum/kvantum.kvconfig".text = ''
    [General]
    theme=libadwaita-kde-dark-orange
  '';
  xdg.configFile."Kvantum/libadwaita-kde-dark-orange" = {
    source = "${pkgs.libadwaita-kde-kvantum}/share/Kvantum/libadwaita-kde-dark-orange";
  };

}
