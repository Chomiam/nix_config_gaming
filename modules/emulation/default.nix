{ config, lib, pkgs, ... }:

let
  cfg = config.chomiamos.emulation;
  cfgUser = config.chomiamos.user.username;

  es-de = pkgs.callPackage ../../pkgs/es-de { };

  update-es-de = pkgs.writers.writePython3Bin "update-es-de" { } (
    builtins.readFile ../../pkgs/es-de/update-es-de.py
  );

  chomiamos-update = pkgs.writeShellScriptBin "chomiamos-update" ''
    set -euo pipefail
    echo "================================================="
    echo "🎮 ChomiamOS — Gestionnaire de Mises à Jour"
    echo "================================================="
    if command -v update-es-de >/dev/null 2>&1; then
      echo "▶ Vérification des composants ES-DE..."
      ${update-es-de}/bin/update-es-de --check || {
        read -r -p "👉 Souhaitez-vous mettre à jour ES-DE maintenant ? [O/n] " answer
        case "$answer" in
          [nN][oO]|[nN]) echo "⏭️ Mise à jour d'ES-DE ignorée." ;;
          *) ${update-es-de}/bin/update-es-de --update ;;
        esac
      }
    fi
    echo "▶ Lancement de la mise à jour système via nh os switch..."
    exec nh os switch "$@"
  '';
in
{
  config = lib.mkIf (cfg.enable || cfg.frontend == "es-de" || cfg.es-de.enable) {
    # Mise à disposition des outils dans le PATH système
    environment.systemPackages = [
      es-de
      update-es-de
      chomiamos-update
    ];

    # Paquets utilisateur pour intégration du lanceur XDG / Desktop
    users.users."${cfgUser}".packages = [
      es-de
    ];

    # Notification / vérification légère au démarrage (si autoCheckUpdates activé)
    systemd.user.services.es-de-update-check = lib.mkIf cfg.es-de.autoCheckUpdates {
      description = "Vérification des mises à jour pour ES-DE (EmulationStation Desktop Edition)";
      wantedBy = [ "default.target" ];
      after = [ "network-online.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = pkgs.writeShellScript "es-de-check-notify" ''
          if ${update-es-de}/bin/update-es-de --check --quiet; then
            exit 0
          else
            if command -v ${pkgs.libnotify}/bin/notify-send >/dev/null 2>&1; then
              ${pkgs.libnotify}/bin/notify-send -i org.es_de.frontend \
                "Mise à jour ES-DE disponible" \
                "Une nouvelle version d'ES-DE est disponible. Tapez 'update-es-de' ou 'chomiamos-update' pour mettre à jour."
            fi
          fi
        '';
      };
    };
  };
}
