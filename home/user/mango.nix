{ ... }:

{
  xdg.configFile."mango/config.conf" = {
    source = ../../configs/mango/config.conf;
    force = true;
  };
}
