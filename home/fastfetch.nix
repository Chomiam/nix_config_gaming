{ pkgs, lib, ... }:

let
  # Définition du caractère Échap (ESC / \u001b) pour qu'il soit correctement sérialisé dans config.jsonc
  esc = builtins.fromJSON "\"\\u001b\"";

  defaultSettings = {
    "$schema" = "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json";
    logo = {
      type = "kitty-direct";
      source = "~/.config/fastfetch/logo/chomiamos_logo.png";
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

  # Wrapper intelligent Fastfetch garantissant le rendu d'images dans tous les terminaux
  fastfetchWrapped = pkgs.symlinkJoin {
    name = "fastfetch-wrapped-${pkgs.fastfetch.version}";
    paths = [ pkgs.fastfetch ];
    postBuild = ''
      rm $out/bin/fastfetch
      cat << 'EOF' > $out/bin/fastfetch
#!/usr/bin/env bash
REAL="${pkgs.fastfetch}/bin/fastfetch"
for arg in "$@"; do
  if [[ "$arg" == --logo-type* ]]; then
    exec "$REAL" "$@"
  fi
done

if [ -n "$KITTY_PID" ] || [ "$TERM" = "xterm-kitty" ]; then
  exec "$REAL" "$@"
elif [ -n "$KONSOLE_VERSION" ] || [ -n "$KONSOLE_DBUS_SERVICE" ]; then
  exec "$REAL" --logo-type chafa "$@"
else
  exec "$REAL" --logo-type chafa "$@"
fi
EOF
      chmod +x $out/bin/fastfetch
    '';
  };
in
{
  # =========================================================================
  # 🐱 MODULE FASTFETCH (PROFIL CATPPUCCIN MACCHIATO & DASHBOARD)
  # =========================================================================

  # Installation du logo officiel chomiamos PNG
  xdg.configFile."fastfetch/logo/chomiamos_logo.png".source = ../assets/chomiamos_fastfetch.png;

  # Version ANSI Art du logo (fallback universel)
  xdg.configFile."fastfetch/logo/catppuccin_logo.txt".source = ./catppuccin_logo.txt;

  # Dépendances pour le rendu d'images dans le terminal (Chafa, ImageMagick, Kitty)
  home.packages = with pkgs; [
    chafa
    imagemagick
    kitty
  ];

  # 1. Profil officiel par défaut ChomiamOS Catppuccin Macchiato
  xdg.configFile."fastfetch/profiles/default.jsonc".source = (pkgs.formats.json { }).generate "default.jsonc" defaultSettings;

  # 2. Binaire Fastfetch installé avec wrapper d'images adaptatif
  programs.fastfetch = {
    enable = true;
    package = fastfetchWrapped;
    settings = { };
  };

  # 3. Gestion déclarative et non-bloquante du lien symbolique config.jsonc
  # Priorité absolue au profil personnalisé Dashboard s'il existe.
  home.activation.fastfetchProfileLink = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ffDir="$HOME/.config/fastfetch"
    profilesDir="$ffDir/profiles"
    configFile="$ffDir/config.jsonc"
    dashboardProfile="$profilesDir/dashboard.jsonc"
    defaultProfile="$profilesDir/default.jsonc"

    $DRY_RUN_CMD mkdir -p "$profilesDir"

    # Si config.jsonc existe et est un fichier régulier (hors lien symbolique),
    # créer une sauvegarde horodatée pour préserver les configurations locales de l'utilisateur
    if [ -f "$configFile" ] && [ ! -L "$configFile" ]; then
      backupFile="$ffDir/config.jsonc.bak.$(date +%s)"
      $DRY_RUN_CMD cp -f "$configFile" "$backupFile"
      $DRY_RUN_CMD rm -f "$configFile"
    fi

    # Si dashboard.jsonc existe et est non vide, pointer dessus ; sinon vers default.jsonc
    if [ -s "$dashboardProfile" ]; then
      $DRY_RUN_CMD ln -sfn "$dashboardProfile" "$configFile"
    elif [ -f "$defaultProfile" ]; then
      $DRY_RUN_CMD ln -sfn "$defaultProfile" "$configFile"
    fi
  '';
}

