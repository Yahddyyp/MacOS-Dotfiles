{ pkgs, ... }:
let
  toml = pkgs.formats.toml { };
in
{
  home.packages = [ pkgs.tuicr ];

  xdg.configFile."tuicr/config.toml".source = toml.generate "tuicr-config.toml" {
    theme = "catppuccin-mocha";
    diff_view = "unified";
    ignore_whitespace = false;
    mouse = true;
    leader = ";";
    review_watch_interval_ms = 1000;

    comment_types = [
      {
        id = "issue";
        color = "red";
        definition = "must fix before merge";
      }
      {
        id = "suggestion";
        color = "blue";
        definition = "optional improvement";
      }
      {
        id = "nit";
        color = "cyan";
        definition = "minor style/cosmetic nitpick, non-blocking";
      }
      {
        id = "praise";
        color = "green";
        definition = "highlight something done well";
      }
      {
        id = "question";
        color = "yellow";
        definition = "clarification requested, not a change";
      }
      {
        id = "note";
        color = "gray";
        definition = "context or info for the author";
      }
      {
        id = "future";
        color = "magenta";
        definition = "follow-up work for a later PR";
      }
    ];
  };
}
