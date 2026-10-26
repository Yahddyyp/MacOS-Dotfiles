{ pkgs, ... }:
{
  services.jankyborders = {
    enable = true;
    package = pkgs.jankyborders;
    active_color = "0xffcba6f7";
    inactive_color = "0x00000000";
    width = 4.0;
    hidpi = true;
    ax_focus = true;
    blacklist = [
      "Steam"
      "Steam Helper"
    ];
  };
}
