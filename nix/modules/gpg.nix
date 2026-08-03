{ pkgs, ... }:
{
  services.gpg-agent = {
    enable = true;
    pinentry = {
      package = pkgs.pinentry-curses;
    };
    defaultCacheTtl = 600;
    maxCacheTtl = 600;
  };
}
