{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    scribus
    libreoffice
    pdfarranger
    kdePackages.okular
    xournalpp
  ];
}
