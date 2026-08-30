{ pkgs, ... }:

let
  # Définition du caractère Échap (ESC / \u001b) pour qu'il soit correctement sérialisé dans config.jsonc
  esc = builtins.fromJSON "\"\\u001b\"";
in
{
  # =========================================================================
  # 🐱 MODULE FASTFETCH (PROFIL CATPPUCCIN MACCHIATO)
  # =========================================================================

  # Téléchargement et installation du logo Catppuccin PNG
  xdg.configFile."fastfetch/logo/catppuccin_logo.png".source = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/Nukecraft5419/fastfetch/main/assets/logo/catppuccin_logo.png";
    hash = "sha256-syWqE+zbTW/e+s40A2iIKD5HD9+lP49MUlDLZFVM+qw=";
  };

  # Version ANSI Art du logo Catppuccin (fallback universel)
  xdg.configFile."fastfetch/logo/catppuccin_logo.txt".source = ./catppuccin_logo.txt;

  # Dépendances pour le rendu d'images dans le terminal (Chafa, ImageMagick, Kitty)
  home.packages = with pkgs; [
    chafa
    imagemagick
    kitty
  ];

  # Configuration déclarative de Fastfetch via Home Manager (génère ~/.config/fastfetch/config.jsonc)
  programs.fastfetch = {
    enable = true;
    settings = {
      "$schema" = "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json";
      logo = {
        type = "kitty-direct";
        source = "~/.config/fastfetch/logo/catppuccin_logo.png";
        width = 40;
        height = 20;
        padding = {
          top = 2;
          left = 2;
          right = 2;
        };
      };
      display = {
        separator = " ${esc}[38;2;198;160;246m${esc}[0m ";
        constants = [
          "${esc}[38;2;240;198;198m─────────────────${esc}[0m"
        ];
        key = {
          type = "icon";
          paddingLeft = 2;
        };
      };
      modules = [
        {
          type = "custom";
          format = "${esc}[38;2;240;198;198m┌${esc}[0m{$1} ${esc}[38;2;198;160;246mHardware Information${esc}[0m {$1}${esc}[38;2;240;198;198m┐${esc}[0m";
        }
        {
          type = "host";
          keyColor = "#f5bde6";
        }
        {
          type = "cpu";
          keyColor = "#f5bde6";
        }
        {
          type = "gpu";
          keyColor = "#f5bde6";
        }
        {
          type = "disk";
          keyColor = "#f5bde6";
        }
        {
          type = "memory";
          keyColor = "#f5bde6";
        }
        {
          type = "display";
          keyColor = "#f5bde6";
        }
        {
          type = "custom";
          format = "${esc}[38;2;240;198;198m└${esc}[0m{$1}${esc}[38;2;240;198;198m──────────────────────${esc}[0m{$1}${esc}[38;2;240;198;198m┘${esc}[0m";
        }
        {
          type = "custom";
          format = "";
        }
        {
          type = "custom";
          format = "${esc}[38;2;240;198;198m┌${esc}[0m{$1} ${esc}[38;2;198;160;246mSoftware Information${esc}[0m {$1}${esc}[38;2;240;198;198m┐${esc}[0m";
        }
        {
          type = "os";
          keyColor = "#f5bde6";
        }
        {
          type = "kernel";
          keyColor = "#f5bde6";
        }
        {
          type = "lm";
          keyColor = "#f5bde6";
        }
        {
          type = "de";
          keyColor = "#f5bde6";
        }
        {
          type = "wm";
          keyColor = "#f5bde6";
        }
        {
          type = "shell";
          keyColor = "#f5bde6";
        }
        {
          type = "terminal";
          keyColor = "#f5bde6";
        }
        {
          type = "font";
          keyColor = "#f5bde6";
        }
        {
          type = "theme";
          keyColor = "#f5bde6";
        }
        {
          type = "icons";
          keyColor = "#f5bde6";
        }
        {
          type = "packages";
          keyColor = "#f5bde6";
        }
        {
          type = "uptime";
          keyColor = "#f5bde6";
        }
        {
          type = "locale";
          keyColor = "#f5bde6";
        }
        {
          type = "custom";
          format = "${esc}[38;2;240;198;198m└${esc}[0m{$1}${esc}[38;2;240;198;198m──────────────────────${esc}[0m{$1}${esc}[38;2;240;198;198m┘${esc}[0m";
        }
        {
          type = "colors";
          symbol = "circle";
          paddingLeft = 21;
        }
      ];
    };
  };
}
