{ pkgs, ... }:

{
  home.packages = with pkgs; [
    waypaper
    awww

  ];

  xdg.configFile = {
    "waypaper/config.ini".source = ../../configs/waypaper/config.ini;

    "waypaper/style.css".source = ../../configs/waypaper/style.css;
  };
}
