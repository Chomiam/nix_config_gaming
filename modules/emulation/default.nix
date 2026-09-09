{ config, lib, pkgs, inputs, ... }:

let
  cfg = config.chomiamos.emulation;
  cfgUser = config.chomiamos.user.username;

  pkgs-unstable = import inputs.nixpkgs-unstable {
    system = pkgs.stdenv.hostPlatform.system;
    config.allowUnfree = true;
  };

  # Frontend ES-DE
  es-de = pkgs.callPackage ../../pkgs/es-de { };

  # Outil CLI de vérification et mise à jour d'ES-DE
  update-es-de = pkgs.writers.writePython3Bin "update-es-de" { } (
    builtins.readFile ../../pkgs/es-de/update-es-de.py
  );

  # Commande unifiée de mise à jour système + ES-DE
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

  # Pack RetroArch avec l'ensemble des cœurs 2D et Arcade recommandés
  retroarchWithCores = pkgs.retroarch.withCores (cores: with pkgs.libretro; [
    # 🕹️ 16-bit & 8-bit Nintendo
    snes9x
    fceumm
    nestopia

    # 🕹️ Sega Master System / Megadrive / Genesis / 32X / Mega-CD
    genesis-plus-gx
    picodrive

    # 🎮 Portables Game Boy / GBC / GBA
    gambatte
    mgba

    # 🎰 Arcade & Neo-Geo
    fbneo
    mame

    # 🎮 3D Rétro & Consoles de salon (fallback RetroArch)
    mupen64plus
    swanstation
    beetle-psx-hw
    beetle-saturn
    flycast
    melonds
    desmume
    beetle-pce-fast
    stella
    prosystem
  ]);

  # Wrapper pour DuckStation (lance la version Flatpak officielle de manière transparente)
  duckstation-bin = pkgs.writeShellScriptBin "duckstation" ''
    exec flatpak run org.duckstation.DuckStation "$@"
  '';

  # Liste des émulateurs autonomes (standalone) sélectionnés
  standalonePackages = [ ]
    ++ lib.optional (cfg.standalone.eden) pkgs-unstable.eden
    ++ lib.optional (cfg.standalone.dolphin) pkgs-unstable.dolphin-emu
    ++ lib.optional (cfg.standalone.pcsx2) pkgs-unstable.pcsx2
    ++ lib.optional (cfg.standalone.ppsspp) pkgs-unstable.ppsspp
    ++ lib.optional (cfg.standalone.melonds) pkgs-unstable.melonds
    ++ lib.optional (cfg.standalone.mgba) pkgs-unstable.mgba
    ++ lib.optional (cfg.standalone.rpcs3) pkgs-unstable.rpcs3
    ++ lib.optional (cfg.standalone.duckstation) duckstation-bin;

in
{
  config = lib.mkIf cfg.enable {
    # 1. Mise à disposition des binaires dans le système
    environment.systemPackages = [
      update-es-de
      chomiamos-update
    ]
    ++ lib.optional (cfg.frontend == "es-de" || cfg.es-de.enable) es-de
    ++ lib.optional cfg.retroarch.enable retroarchWithCores
    ++ standalonePackages;

    # 2. Ajout des raccourcis au profil utilisateur
    users.users."${cfgUser}".packages = [ ]
      ++ lib.optional (cfg.frontend == "es-de" || cfg.es-de.enable) es-de
      ++ lib.optional cfg.retroarch.enable retroarchWithCores
      ++ standalonePackages;

    # 3. Installation automatique de DuckStation via Flatpak si activé
    services.flatpak.packages = lib.optional cfg.standalone.duckstation "org.duckstation.DuckStation";

    # 4. Création déclarative de l'arborescence des ROMs et BIOS
    system.activationScripts.emulationDirs = lib.stringAfter [ "users" ] ''
      homeDir="/home/${cfgUser}"
      if [ -d "$homeDir" ]; then
        romsDir="$homeDir/Jeux/ROMs"
        biosDir="$homeDir/Jeux/BIOS"
        mkdir -p "$romsDir"/{snes,megadrive,nes,gba,gbc,gb,n64,nds,gamecube,wii,switch,psx,ps2,psp,arcade} "$biosDir"
        chown -R ${cfgUser}:users "$homeDir/Jeux"
        chmod -R u+rwX,g+rwX "$homeDir/Jeux"
      fi
    '';

    # 5. Service systemd de notification des màj d'ES-DE au démarrage
    systemd.user.services.es-de-update-check = lib.mkIf (cfg.es-de.enable && cfg.es-de.autoCheckUpdates) {
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
