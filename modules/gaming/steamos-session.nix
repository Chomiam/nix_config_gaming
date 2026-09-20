{ config, lib, pkgs, ... }:

let
  cfg = config.chomiamos;
  enableGamescopeSession = cfg.gaming.enable && cfg.gaming.launchers.steam && cfg.gaming.gamescopeSession;

  # =========================================================================
  # 🎮 steamos-session-select : Retour à l'écran de connexion
  # Appelé par Steam Big Picture via le bouton "Retour au bureau"
  # Termine la session Wayland Gamescope → le display manager reprend la main
  # Fonctionne avec GDM, SDDM, LightDM, cosmic-greeter (universel)
  # =========================================================================
  steamos-session-select = pkgs.writeShellScriptBin "steamos-session-select" ''
    export PATH="${lib.makeBinPath [ pkgs.coreutils pkgs.systemd pkgs.util-linux ]}:$PATH"
    set -uo pipefail

    # Journalisation de l'événement
    logger -t steamos-session-select "Demande de retour au bureau (UID: $(id -u), session: ''${XDG_SESSION_ID:-inconnue})" || true

    # Termine la session Wayland Gamescope → retour à l'écran de connexion du display manager
    if [ -n "''${XDG_SESSION_ID:-}" ]; then
      loginctl terminate-session "$XDG_SESSION_ID"
    else
      # Fallback : termine la session de l'utilisateur courant
      loginctl terminate-user "$(id -u)"
    fi
  '';

  steamosctl = pkgs.writeShellScriptBin "steamosctl" ''
    export PATH="${lib.makeBinPath [ pkgs.coreutils pkgs.systemd ]}:$PATH"
    set -uo pipefail

    case "''${1:-}" in
      switch-to-desktop-mode|switch-to-desktop)
        exec ${steamos-session-select}/bin/steamos-session-select
        ;;
      *)
        exit 0
        ;;
    esac
  '';

  steamGamescopeDesktopItem = pkgs.makeDesktopItem {
    name = "steam-gamescope";
    desktopName = "Steam (Mode Console)";
    genericName = "Steam GameScope Session";
    comment = "Lancer Steam en mode grand écran console (GameScope / Steam Deck UI)";
    exec = "steam-gamescope";
    icon = "steam";
    terminal = false;
    categories = [ "Game" ];
  };
in
{
  config = lib.mkIf enableGamescopeSession {
    # Rendre les utilitaires accessibles dans le conteneur Steam FHS
    programs.steam.extraPackages = [
      steamos-session-select
      steamosctl
    ];

    # Rendre les utilitaires et le lanceur accessibles dans tout le système
    environment.systemPackages = [
      steamos-session-select
      steamosctl
      steamGamescopeDesktopItem
    ];
  };
}

