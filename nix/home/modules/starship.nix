{ ... }:
{
  programs.starship = {
    enable = true;

    settings = {
      format = builtins.concatStringsSep "" [
        "[](sapphire)"
        "$os"
        "$username"
        "[](bg:mauve fg:sapphire)"
        "$directory"
        "[](bg:green fg:mauve)"
        "$git_branch"
        "$git_status"
        "[](fg:green bg:sky)"
        "$c"
        "$rust"
        "$golang"
        "$nodejs"
        "$php"
        "$java"
        "$kotlin"
        "$haskell"
        "$python"
        "$docker_context"
        "[](fg:sky bg:lavender)"
        "$time"
        "[ ](fg:lavender)"
        "$cmd_duration"
        "$line_break"
        "$character"
      ];

      palette = "catppuccin_mocha";

      os = {
        disabled = false;
        style = "bg:sapphire fg:crust";
        format = "[$symbol ]($style)";
        symbols = {
          AOSC = "";
          Alpine = "";
          Amazon = "";
          Android = "";
          Arch = "󰣇";
          Artix = "󰣇";
          CentOS = "";
          Debian = "󰣚";
          Fedora = "󰣛";
          Gentoo = "󰣨";
          Linux = "󰌽";
          Macos = "󰀵";
          Manjaro = "";
          Mint = "󰣭";
          Raspbian = "󰐿";
          RedHatEnterprise = "󱄛";
          Redhat = "󱄛";
          SUSE = "";
          Ubuntu = "󰕈";
          Windows = "";
        };
      };

      username = {
        show_always = false;
        style_user = "bg:red fg:crust";
        style_root = "bg:red fg:crust";
        format = "[ $user]($style)";
      };

      directory = {
        style = "bg:mauve fg:crust";
        format = "[ $path ]($style)";
        truncation_length = 3;
        truncation_symbol = "…/";
        substitutions = {
          "Documents" = "󰈙 ";
          "Downloads" = " ";
          "Music" = "󰝚 ";
          "Pictures" = " ";
          "Developer" = "󰲋 ";
        };
      };

      git_branch = {
        symbol = "";
        style = "bg:green";
        format = "[[ $symbol $branch ](fg:crust bg:green)]($style)";
      };

      git_status = {
        style = "bg:green";
        format = "[[($ahead_behind$stashed$conflicted$staged$modified$deleted$renamed$untracked)](fg:crust bg:green)]($style)";
        modified = "!\${count} ";
        staged = "+\${count} ";
        untracked = "?\${count} ";
        deleted = "✘\${count} ";
        renamed = "»\${count} ";
        conflicted = "~\${count} ";
        stashed = "*\${count} ";
        ahead = "⇡\${count} ";
        behind = "⇣\${count} ";
        diverged = "⇣\${behind_count}⇡\${ahead_count} ";
      };

      nodejs = {
        symbol = "";
        style = "bg:sapphire";
        format = "[[ $symbol( $version) ](fg:crust bg:sky)]($style)";
      };

      c = {
        symbol = " ";
        style = "bg:sapphire";
        format = "[[ $symbol( $version) ](fg:crust bg:sky)]($style)";
      };

      rust = {
        symbol = "";
        style = "bg:sapphire";
        format = "[[ $symbol( $version) ](fg:crust bg:sky)]($style)";
      };

      golang = {
        symbol = "";
        style = "bg:sapphire";
        format = "[[ $symbol( $version) ](fg:crust bg:sky)]($style)";
      };

      php = {
        symbol = "";
        style = "bg:sapphire";
        format = "[[ $symbol( $version) ](fg:crust bg:sky)]($style)";
      };

      java = {
        symbol = "";
        style = "bg:sapphire";
        format = "[[ $symbol( $version) ](fg:crust bg:sky)]($style)";
      };

      kotlin = {
        symbol = "";
        style = "bg:sapphire";
        format = "[[ $symbol( $version) ](fg:crust bg:sky)]($style)";
      };

      haskell = {
        symbol = "";
        style = "bg:sapphire";
        format = "[[ $symbol( $version) ](fg:crust bg:sky)]($style)";
      };

      python = {
        symbol = "";
        style = "bg:sapphire";
        format = "[[ $symbol( $version)(\\(#$virtualenv\\)) ](fg:crust bg:sky)]($style)";
      };

      docker_context = {
        symbol = "";
        style = "bg:sapphire";
        format = "[[ $symbol( $context) ](fg:crust bg:sky)]($style)";
      };

      time = {
        disabled = false;
        time_format = "%I:%M %p";
        style = "bg:lavender";
        format = "[[  $time ](fg:crust bg:lavender)]($style)";
      };

      character = {
        disabled = false;
        success_symbol = "[❯](bold fg:mauve)";
        error_symbol = "[❯](bold fg:red)";
        vimcmd_symbol = "[❮](bold fg:mauve)";
        vimcmd_replace_one_symbol = "[❮](bold fg:mauve)";
        vimcmd_replace_symbol = "[❮](bold fg:mauve)";
        vimcmd_visual_symbol = "[V](bold fg:mauve)";
      };

      cmd_duration = {
        disabled = false;
        min_time = 3000;
        show_milliseconds = false;
        format = "[󱦟 $duration](fg:overlay1)";
        show_notifications = true;
        min_time_to_notify = 45000;
      };

      palettes.catppuccin_mocha = {
        rosewater = "#f5e0dc";
        flamingo = "#f2cdcd";
        pink = "#f5c2e7";
        mauve = "#cba6f7";
        red = "#f38ba8";
        maroon = "#eba0ac";
        peach = "#fab387";
        yellow = "#f9e2af";
        green = "#a6e3a1";
        teal = "#94e2d5";
        sky = "#89dceb";
        sapphire = "#74c7ec";
        blue = "#89b4fa";
        lavender = "#b4befe";
        text = "#cdd6f4";
        subtext1 = "#bac2de";
        subtext0 = "#a6adc8";
        overlay2 = "#9399b2";
        overlay1 = "#7f849c";
        overlay0 = "#6c7086";
        surface2 = "#585b70";
        surface1 = "#45475a";
        surface0 = "#313244";
        base = "#1e1e2e";
        mantle = "#181825";
        crust = "#11111b";
      };
    };
  };
}
