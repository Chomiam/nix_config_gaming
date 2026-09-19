{ config, lib, pkgs, inputs, ... }:

let
  cfg = config.chomiamos.emulation;
  cfgUser = config.chomiamos.user.username;

  pkgs-unstable = import inputs.nixpkgs-unstable {
    system = pkgs.stdenv.hostPlatform.system;
    config.allowUnfree = true;
  };

  # Frontend ES-DE brut
  es-de-base = pkgs.callPackage ../../pkgs/es-de { };

  # Émulateur PlayStation 1 DuckStation autonome (compilé depuis les sources)
  duckstationPkg = inputs.duckstation.packages.${pkgs.stdenv.hostPlatform.system}.duckstation;

  # Émulateurs devant être accessibles directement dans le PATH d'ES-DE (dont Eden et DuckStation)
  emulatorsPath = lib.makeBinPath (
    [ pkgs-unstable.eden pkgs.flatpak ]
    ++ standalonePackages
    ++ lib.optional cfg.retroarch.enable retroarchWithCores
  );

  # Frontend ES-DE enveloppé avec le PATH des émulateurs et protection contre les plantages
  es-de = pkgs.symlinkJoin {
    name = "es-de-${es-de-base.version}";
    paths = [ es-de-base ];
    postBuild = ''
      rm -f $out/bin/es-de
      cat << 'LAUNCHER_EOF' > $out/bin/es-de
#!${pkgs.bash}/bin/bash
set -euo pipefail

# 1. Éviter le plantage bubblewrap si lancé depuis un répertoire non accessible (ex: /etc)
if [[ "''${PWD:-}" == /etc* ]] || [ ! -d "''${PWD:-}" ]; then
  cd "$HOME"
fi

export PATH="${emulatorsPath}:$PATH"

# 2. Sécurisation déclarative du dossier des ROMs
settingsDir="$HOME/ES-DE/settings"
settingsFile="$settingsDir/es_settings.xml"
mkdir -p "$settingsDir"

targetRoms="${cfg.romsDir}"
fallbackRoms="$HOME/Jeux/ROMs"

if [ ! -f "$settingsFile" ]; then
  cat << INIT_SETTINGS_EOF > "$settingsFile"
<?xml version="1.0"?>
<string name="ROMDirectory" value="$targetRoms/" />
INIT_SETTINGS_EOF
else
  # Remplacer tout ancien chemin obsolète /mnt/Games
  sed -i "s|/mnt/Games/Emulation/roms/*|$targetRoms/|g" "$settingsFile" 2>/dev/null || true

  # Lire le dossier de ROMs actuellement configuré
  configuredRoms=$(grep 'name="ROMDirectory"' "$settingsFile" | sed -n 's/.*value="\([^"]*\)".*/\1/p' || true)

  if [ -z "$configuredRoms" ]; then
    echo "<string name=\"ROMDirectory\" value=\"$targetRoms/\" />" >> "$settingsFile"
    configuredRoms="$targetRoms"
  fi

  # Vérifier l'accessibilité du dossier configuré (disque externe ou point de montage)
  if ! mkdir -p "$configuredRoms" 2>/dev/null; then
    if command -v notify-send >/dev/null 2>&1; then
      notify-send -i org.es_de.frontend \
        "ES-DE : Dossier de ROMs inaccessible" \
        "Le dossier '$configuredRoms' n'est pas accessible. Utilisation temporaire du dossier local '$fallbackRoms'."
    fi
    mkdir -p "$fallbackRoms"
    sed -i "s|<string name=\"ROMDirectory\" value=\"[^\"]*\" />|<string name=\"ROMDirectory\" value=\"$fallbackRoms/\" />|" "$settingsFile"
  fi
fi

exec "${es-de-base}/bin/es-de" "$@"
LAUNCHER_EOF
      chmod +x $out/bin/es-de
    '';
  };

  # Outil CLI de vérification et mise à jour d'ES-DE
  update-es-de = pkgs.writers.writePython3Bin "update-es-de" { doCheck = false; } (
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

    # 🎮 PlayStation 1 (SwanStation haute performance & Beetle PSX HW précision)
    swanstation
    beetle-psx-hw

    # 🎮 3D Rétro & Consoles de salon
    mupen64plus
    beetle-saturn
    flycast
    melonds
    desmume
    beetle-pce-fast
    stella
    prosystem
  ]);

  # Liste des émulateurs autonomes (standalone) sélectionnés
  standalonePackages = [ ]
    ++ lib.optional (cfg.standalone.duckstation) duckstationPkg
    ++ lib.optional (cfg.standalone.eden) pkgs-unstable.eden
    ++ lib.optional (cfg.standalone.dolphin) pkgs-unstable.dolphin-emu
    ++ lib.optional (cfg.standalone.pcsx2) pkgs-unstable.pcsx2
    ++ lib.optional (cfg.standalone.ppsspp) pkgs-unstable.ppsspp
    ++ lib.optional (cfg.standalone.melonds) pkgs-unstable.melonds
    ++ lib.optional (cfg.standalone.mgba) pkgs-unstable.mgba
    ++ lib.optional (cfg.standalone.azahar) pkgs-unstable.azahar
    ++ lib.optional (cfg.standalone.cemu) pkgs.cemu
    ++ lib.optional (cfg.standalone.xenia-canary) pkgs-unstable."xenia-canary";

in
{
  config = lib.mkIf cfg.enable {
    # Déclaration des paquets Flatpak Flathub pour l'émulation
    services.flatpak.packages = [ ]
      ++ lib.optional cfg.standalone.rpcs3 "net.rpcs3.RPCS3"
      ++ lib.optional cfg.standalone.xemu "app.xemu.xemu";

    # Permissions Flatpak : garantit l'accès aux dossiers de ROMs (~/Jeux, /mnt, /media)
    services.flatpak.overrides = lib.mkMerge [
      (lib.mkIf cfg.standalone.rpcs3 {
        "net.rpcs3.RPCS3" = {
          Context = {
            filesystems = [
              "home"
              "/mnt"
              "/media"
              "/run/media"
            ];
          };
        };
      })
      (lib.mkIf cfg.standalone.xemu {
        "app.xemu.xemu" = {
          Context = {
            filesystems = [
              "home"
              "/mnt"
              "/media"
              "/run/media"
            ];
          };
        };
      })
    ];

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

    # 3. Création déclarative de l'arborescence des ROMs et BIOS
    system.activationScripts.emulationDirs = lib.stringAfter [ "users" ] ''
      homeDir="/home/${cfgUser}"
      if [ -d "$homeDir" ]; then
        # 1. Rétrocompatibilité /mnt/Games -> /mnt/Emudeck
        if [ -d "/mnt/Games" ] && [ ! -L "/mnt/Games" ]; then
          rmdir "/mnt/Games" 2>/dev/null || true
        fi
        if [ ! -e "/mnt/Games" ] && [ -d "/mnt/Emudeck" ]; then
          ln -sfn /mnt/Emudeck /mnt/Games
        fi

        # 2. Gestion déclarative des ROMs et BIOS
        targetRoms="${cfg.romsDir}"
        targetBios="${cfg.biosDir}"
        localRoms="$homeDir/Jeux/ROMs"
        localBios="$homeDir/Jeux/BIOS"

        mkdir -p "$homeDir/Jeux"

        # Lier ou initialiser le dossier des ROMs
        if [ -d "$targetRoms" ]; then
          # Si localRoms est un dossier vide (ou seulement des sous-dossiers vides), le remplacer par le lien symbolique
          if [ -d "$localRoms" ] && [ ! -L "$localRoms" ]; then
            if [ -z "$(find "$localRoms" -mindepth 2 -type f 2>/dev/null)" ]; then
              rm -rf "$localRoms"
              ln -sfn "$targetRoms" "$localRoms"
            fi
          elif [ ! -e "$localRoms" ]; then
            ln -sfn "$targetRoms" "$localRoms"
          fi
        else
          # Fallback local si le stockage externe est débranché
          if [ ! -L "$localRoms" ]; then
            mkdir -p "$localRoms"/{snes,megadrive,nes,gba,gbc,gb,n64,nds,n3ds,gamecube,wii,wiiu,switch,psx,ps2,ps3,psp,arcade,xbox,xbox360}
            ln -sfn "$localRoms/n3ds" "$localRoms/3ds"
          fi
        fi

        # Lier ou initialiser le dossier des BIOS
        if [ -d "$targetBios" ]; then
          if [ -d "$localBios" ] && [ ! -L "$localBios" ]; then
            if [ -z "$(ls -A "$localBios" 2>/dev/null)" ]; then
              rm -rf "$localBios"
              ln -sfn "$targetBios" "$localBios"
            fi
          elif [ ! -e "$localBios" ]; then
            ln -sfn "$targetBios" "$localBios"
          fi

          # Raccordement direct pour RetroArch system (2.8 Go de BIOS)
          mkdir -p "$homeDir/.config/retroarch"
          if [ -d "$homeDir/.config/retroarch/system" ] && [ ! -L "$homeDir/.config/retroarch/system" ]; then
            if [ -z "$(ls -A "$homeDir/.config/retroarch/system" 2>/dev/null)" ]; then
              rm -rf "$homeDir/.config/retroarch/system"
              ln -sfn "$targetBios" "$homeDir/.config/retroarch/system"
            fi
          elif [ ! -e "$homeDir/.config/retroarch/system" ]; then
            ln -sfn "$targetBios" "$homeDir/.config/retroarch/system"
          fi
        else
          if [ ! -L "$localBios" ]; then
            mkdir -p "$localBios"
          fi
        fi

        chown -R ${cfgUser}:users "$homeDir/Jeux" 2>/dev/null || true
        chmod -R u+rwX,g+rwX "$homeDir/Jeux" 2>/dev/null || true

        # 3. Initialisation et nettoyage de la configuration ES-DE
        settingsDir="$homeDir/ES-DE/settings"
        settingsFile="$settingsDir/es_settings.xml"
        mkdir -p "$settingsDir"
        if [ ! -f "$settingsFile" ]; then
          cat << 'ES_INIT_SETTINGS_EOF' > "$settingsFile"
<?xml version="1.0"?>
<string name="ROMDirectory" value="${cfg.romsDir}/" />
ES_INIT_SETTINGS_EOF
          chown -R ${cfgUser}:users "$homeDir/ES-DE"
        else
          # Corriger tout chemin obsolète /mnt/Games
          sed -i "s|/mnt/Games/Emulation/roms/*|${cfg.romsDir}/|g" "$settingsFile" 2>/dev/null || true
        fi

        # Raccourcis locaux de détection statique pour ES-DE
        mkdir -p "$homeDir/.local/bin"
        ${lib.optionalString cfg.standalone.eden ''
          ln -sfn "${pkgs-unstable.eden}/bin/eden" "$homeDir/.local/bin/eden"
          chown -h ${cfgUser}:users "$homeDir/.local/bin/eden" || true
        ''}

        ${lib.optionalString cfg.standalone.duckstation ''
          ln -sfn "${duckstationPkg}/bin/duckstation" "$homeDir/.local/bin/duckstation"
          ln -sfn "${duckstationPkg}/bin/duckstation-qt" "$homeDir/.local/bin/duckstation-qt"
          chown -h ${cfgUser}:users "$homeDir/.local/bin/duckstation"* || true
        ''}

        ${lib.optionalString cfg.standalone.pcsx2 ''
          ln -sfn "${pkgs-unstable.pcsx2}/bin/pcsx2-qt" "$homeDir/.local/bin/pcsx2-qt"
          ln -sfn "${pkgs-unstable.pcsx2}/bin/pcsx2-qt" "$homeDir/.local/bin/pcsx2"
          chown -h ${cfgUser}:users "$homeDir/.local/bin/pcsx2"* || true
        ''}

        ${lib.optionalString cfg.standalone.xemu ''
          rm -f "$homeDir/.local/bin/xemu"
          cat << 'XEMU_BIN_EOF' > "$homeDir/.local/bin/xemu"
#!/bin/sh
if [ -x /var/lib/flatpak/exports/bin/app.xemu.xemu ]; then
  exec /var/lib/flatpak/exports/bin/app.xemu.xemu "$@"
elif [ -x "$HOME/.local/share/flatpak/exports/bin/app.xemu.xemu" ]; then
  exec "$HOME/.local/share/flatpak/exports/bin/app.xemu.xemu" "$@"
else
  exec flatpak run app.xemu.xemu "$@"
fi
XEMU_BIN_EOF
          chmod +x "$homeDir/.local/bin/xemu"
          ln -sfn "$homeDir/.local/bin/xemu" "$homeDir/.local/bin/xemu.AppImage"
          chown -h ${cfgUser}:users "$homeDir/.local/bin/xemu"* || true

          # Continuité des données et de l'EEPROM xemu Flatpak
          mkdir -p "$homeDir/.var/app/app.xemu.xemu/data/xemu"
          if [ -d "$homeDir/.local/share/xemu/xemu" ] && [ ! -e "$homeDir/.var/app/app.xemu.xemu/data/xemu/xemu.toml" ]; then
            cp -rn "$homeDir/.local/share/xemu/xemu/"* "$homeDir/.var/app/app.xemu.xemu/data/xemu/" 2>/dev/null || true
          fi
          chown -R ${cfgUser}:users "$homeDir/.var/app/app.xemu.xemu" || true
        ''}

        ${lib.optionalString cfg.standalone.cemu ''
          ln -sfn "${pkgs.cemu}/bin/cemu" "$homeDir/.local/bin/cemu"
          ln -sfn "${pkgs.cemu}/bin/Cemu" "$homeDir/.local/bin/Cemu"
          chown -h ${cfgUser}:users "$homeDir/.local/bin/cemu"* "$homeDir/.local/bin/Cemu"* || true
        ''}

        ${lib.optionalString cfg.standalone.xenia-canary ''
          ln -sfn "${pkgs-unstable."xenia-canary"}/bin/xenia_canary" "$homeDir/.local/bin/xenia_canary"
          ln -sfn "${pkgs-unstable."xenia-canary"}/bin/xenia_canary" "$homeDir/.local/bin/xenia-canary"
          ln -sfn "${pkgs-unstable."xenia-canary"}/bin/xenia_canary" "$homeDir/.local/bin/xenia"
          chown -h ${cfgUser}:users "$homeDir/.local/bin/xenia"* || true
        ''}

        ${lib.optionalString cfg.standalone.rpcs3 ''
          rm -f "$homeDir/.local/bin/rpcs3"
          cat << 'RPCS3_BIN_EOF' > "$homeDir/.local/bin/rpcs3"
#!/bin/sh
if [ -x /var/lib/flatpak/exports/bin/net.rpcs3.RPCS3 ]; then
  exec /var/lib/flatpak/exports/bin/net.rpcs3.RPCS3 "$@"
elif [ -x "$HOME/.local/share/flatpak/exports/bin/net.rpcs3.RPCS3" ]; then
  exec "$HOME/.local/share/flatpak/exports/bin/net.rpcs3.RPCS3" "$@"
else
  exec flatpak run net.rpcs3.RPCS3 "$@"
fi
RPCS3_BIN_EOF
          chmod +x "$homeDir/.local/bin/rpcs3"
          ln -sfn "$homeDir/.local/bin/rpcs3" "$homeDir/.local/bin/rpcs3.AppImage"
          chown -h ${cfgUser}:users "$homeDir/.local/bin/rpcs3"* || true

          # Continuité des données/sauvegardes RPCS3 Flatpak
          mkdir -p "$homeDir/.var/app/net.rpcs3.RPCS3/config"
          if [ -d "$homeDir/.config/rpcs3" ] && [ ! -e "$homeDir/.var/app/net.rpcs3.RPCS3/config/rpcs3" ]; then
            cp -rn "$homeDir/.config/rpcs3" "$homeDir/.var/app/net.rpcs3.RPCS3/config/" || true
          fi
          chown -R ${cfgUser}:users "$homeDir/.var/app/net.rpcs3.RPCS3" || true
        ''}

        # 4. Configuration déclarative d'ES-DE : DuckStation (PSX), PCSX2 (PS2), RPCS3 (PS3) et xemu (Xbox) par défaut
        mkdir -p "$homeDir/ES-DE/custom_systems"
        cat << 'CUSTOM_SYS_EOF' > "$homeDir/ES-DE/custom_systems/es_systems.xml"
<?xml version="1.0"?>
<!-- Configuration personnalisée ChomiamOS pour ES-DE -->
<systemList>
    <!-- Sony PlayStation 1 : DuckStation (Standalone) par défaut -->
    <system>
        <name>psx</name>
        <fullname>Sony PlayStation</fullname>
        <path>%ROMPATH%/psx</path>
        <extension>.bin .BIN .cbn .CBN .ccd .CCD .chd .CHD .cue .CUE .ecm .ECM .exe .EXE .img .IMG .iso .ISO .m3u .M3U .mdf .MDF .mds .MDS .minipsf .MINIPSF .pbp .PBP .psexe .PSEXE .psf .PSF .toc .TOC .z .Z .znx .ZNX .7z .7Z .zip .ZIP</extension>
        <command label="DuckStation (Standalone)">%EMULATOR_DUCKSTATION% -batch %ROM%</command>
        <command label="SwanStation">%EMULATOR_RETROARCH% -L %CORE_RETROARCH%/swanstation_libretro.so %ROM%</command>
        <command label="Beetle PSX HW">%EMULATOR_RETROARCH% -L %CORE_RETROARCH%/mednafen_psx_hw_libretro.so %ROM%</command>
        <command label="Beetle PSX">%EMULATOR_RETROARCH% -L %CORE_RETROARCH%/mednafen_psx_libretro.so %ROM%</command>
        <command label="PCSX ReARMed">%EMULATOR_RETROARCH% -L %CORE_RETROARCH%/pcsx_rearmed_libretro.so %ROM%</command>
        <command label="ares (Standalone)">%EMULATOR_ARES% --fullscreen --system "PlayStation" %ROM%</command>
        <command label="Mednafen (Standalone)">%EMULATOR_MEDNAFEN% -force_module psx %ROM%</command>
        <platform>psx</platform>
        <theme>psx</theme>
    </system>

    <!-- Sony PlayStation 2 : PCSX2 (Standalone) par défaut -->
    <system>
        <name>ps2</name>
        <fullname>Sony PlayStation 2</fullname>
        <path>%ROMPATH%/ps2</path>
        <extension>.bin .BIN .chd .CHD .ciso .CISO .cso .CSO .desktop .dump .DUMP .elf .ELF .gz .GZ .m3u .M3U .mdf .MDF .img .IMG .iso .ISO .isz .ISZ .ngr .NRG .zso .ZSO</extension>
        <command label="PCSX2 (Standalone)">%EMULATOR_PCSX2% -batch %ROM%</command>
        <command label="PCSX2 Legacy (Standalone)">%EMULATOR_PCSX2-LEGACY% --nogui %ROM%</command>
        <command label="LRPS2">%EMULATOR_RETROARCH% -L %CORE_RETROARCH%/pcsx2_libretro.so %ROM%</command>
        <command label="PCSX2">%EMULATOR_RETROARCH% -L %CORE_RETROARCH%/pcsx2_libretro.so %ROM%</command>
        <command label="Play! (Standalone)">%EMULATOR_PLAY!% --fullscreen --disc %ROM%</command>
        <command label="Shortcut or script">%ENABLESHORTCUTS% %EMULATOR_OS-SHELL% %ROM%</command>
        <platform>ps2</platform>
        <theme>ps2</theme>
    </system>

    <!-- Microsoft Xbox : xemu (Standalone) par défaut -->
    <system>
        <name>xbox</name>
        <fullname>Microsoft Xbox</fullname>
        <path>%ROMPATH%/xbox</path>
        <extension>.iso .ISO .xiso .XISO</extension>
        <command label="xemu (Standalone)">%INJECT%=%BASENAME%.esprefix %EMULATOR_XEMU% -dvd_path %ROM%</command>
        <command label="xemu Standalone (Direct)">~/.local/bin/xemu -dvd_path %ROM%</command>
        <command label="xemu Flatpak (Direct)">/var/lib/flatpak/exports/bin/app.xemu.xemu -dvd_path %ROM%</command>
        <command label="Shortcut or script">%ENABLESHORTCUTS% %EMULATOR_OS-SHELL% %ROM%</command>
        <platform>xbox</platform>
        <theme>xbox</theme>
    </system>

    <!-- Sony PlayStation 3 : RPCS3 (Standalone) par défaut -->
    <system>
        <name>ps3</name>
        <fullname>Sony PlayStation 3</fullname>
        <path>%ROMPATH%/ps3</path>
        <extension>.desktop .iso .ISO .ps3 .PS3 .ps3dir .PS3DIR</extension>
        <command label="RPCS3 (Standalone)">%EMULATOR_RPCS3% --no-gui %ROM%</command>
        <command label="RPCS3 Standalone (Direct)">~/.local/bin/rpcs3 --no-gui %ROM%</command>
        <command label="RPCS3 Flatpak (Direct)">/var/lib/flatpak/exports/bin/net.rpcs3.RPCS3 --no-gui %ROM%</command>
        <command label="RPCS3 ISO (Standalone)">%EMULATOR_RPCS3% --no-gui %ROM%</command>
        <command label="RPCS3 Directory (Standalone)">%EMULATOR_RPCS3% --no-gui %ROM%</command>
        <command label="RPCS3 Game Serial (Standalone)">%EMULATOR_RPCS3% --no-gui %RPCS3_GAMEID%:%INJECT%=%BASENAME%.ps3</command>
        <command label="RPCS3 Shortcut (Standalone)">%ENABLESHORTCUTS% %EMULATOR_OS-SHELL% %ROM%</command>
        <platform>ps3</platform>
        <theme>ps3</theme>
    </system>
</systemList>
CUSTOM_SYS_EOF

        # Définition déclarative des règles de détection (find rules) pour ES-DE
        cat << 'FIND_RULES_EOF' > "$homeDir/ES-DE/custom_systems/es_find_rules.xml"
<?xml version="1.0"?>
<!-- Règles personnalisées ChomiamOS pour la détection des émulateurs dans ES-DE -->
<ruleList>
    <emulator name="XEMU">
        <!-- Émulateur Microsoft Xbox xemu (Flatpak / Standalone) -->
        <rule type="systempath">
            <entry>xemu</entry>
            <entry>app.xemu.xemu</entry>
        </rule>
        <rule type="staticpath">
            <entry>/var/lib/flatpak/exports/bin/app.xemu.xemu</entry>
            <entry>~/.local/share/flatpak/exports/bin/app.xemu.xemu</entry>
            <entry>~/.local/bin/xemu</entry>
            <entry>/run/current-system/sw/bin/xemu</entry>
            <entry>~/.local/bin/xemu.AppImage</entry>
            <entry>/etc/profiles/per-user/${cfgUser}/bin/xemu</entry>
            <entry>~/Applications/xemu*.AppImage</entry>
            <entry>~/.local/share/applications/xemu*.AppImage</entry>
            <entry>~/bin/xemu*.AppImage</entry>
        </rule>
    </emulator>
    <emulator name="DUCKSTATION">
        <!-- Émulateur PlayStation 1 DuckStation (Standalone NixOS) -->
        <rule type="systempath">
            <entry>duckstation-nogui</entry>
            <entry>duckstation-qt</entry>
            <entry>duckstation</entry>
            <entry>org.duckstation.DuckStation</entry>
        </rule>
        <rule type="staticpath">
            <entry>/run/current-system/sw/bin/duckstation</entry>
            <entry>/run/current-system/sw/bin/duckstation-qt</entry>
            <entry>~/.local/bin/duckstation</entry>
            <entry>~/.local/bin/duckstation-qt</entry>
        </rule>
    </emulator>
    <emulator name="PCSX2">
        <!-- Émulateur PlayStation 2 PCSX2 (Standalone NixOS) -->
        <rule type="systempath">
            <entry>pcsx2-qt</entry>
            <entry>pcsx2</entry>
            <entry>net.pcsx2.PCSX2</entry>
        </rule>
        <rule type="staticpath">
            <entry>/run/current-system/sw/bin/pcsx2</entry>
            <entry>/run/current-system/sw/bin/pcsx2-qt</entry>
            <entry>~/.local/bin/pcsx2</entry>
            <entry>~/.local/bin/pcsx2-qt</entry>
        </rule>
    </emulator>
    <emulator name="CEMU">
        <!-- Émulateur Nintendo Wii U Cemu (Standalone NixOS) -->
        <rule type="systempath">
            <entry>cemu</entry>
            <entry>Cemu</entry>
        </rule>
        <rule type="staticpath">
            <entry>/run/current-system/sw/bin/cemu</entry>
            <entry>/run/current-system/sw/bin/Cemu</entry>
            <entry>~/.local/bin/cemu</entry>
            <entry>~/.local/bin/Cemu</entry>
        </rule>
    </emulator>
    <emulator name="XENIA">
        <!-- Émulateur Microsoft Xbox 360 Xenia Canary (Standalone NixOS) -->
        <rule type="systempath">
            <entry>xenia_canary</entry>
            <entry>xenia-canary</entry>
            <entry>xenia</entry>
        </rule>
        <rule type="staticpath">
            <entry>/run/current-system/sw/bin/xenia_canary</entry>
            <entry>/run/current-system/sw/bin/xenia-canary</entry>
            <entry>/run/current-system/sw/bin/xenia</entry>
            <entry>~/.local/bin/xenia_canary</entry>
            <entry>~/.local/bin/xenia-canary</entry>
            <entry>~/.local/bin/xenia</entry>
        </rule>
    </emulator>
    <emulator name="RPCS3">
        <!-- Émulateur Sony PlayStation 3 RPCS3 (Flatpak / Standalone) -->
        <rule type="systempath">
            <entry>rpcs3</entry>
            <entry>net.rpcs3.RPCS3</entry>
        </rule>
        <rule type="staticpath">
            <entry>/var/lib/flatpak/exports/bin/net.rpcs3.RPCS3</entry>
            <entry>~/.local/share/flatpak/exports/bin/net.rpcs3.RPCS3</entry>
            <entry>~/.local/bin/rpcs3</entry>
            <entry>/run/current-system/sw/bin/rpcs3</entry>
            <entry>~/.local/bin/rpcs3.AppImage</entry>
            <entry>/etc/profiles/per-user/${cfgUser}/bin/rpcs3</entry>
            <entry>~/Applications/rpcs3*.AppImage</entry>
            <entry>~/.local/share/applications/rpcs3*.AppImage</entry>
            <entry>~/bin/rpcs3*.AppImage</entry>
        </rule>
    </emulator>
</ruleList>
FIND_RULES_EOF
        chown -R ${cfgUser}:users "$homeDir/ES-DE/custom_systems"

        # Initialisation déclarative des alternativeEmulator dans les gamelists ES-DE
        mkdir -p "$homeDir/ES-DE/gamelists/ps2" "$homeDir/ES-DE/gamelists/psx" "$homeDir/ES-DE/gamelists/ps3" "$homeDir/ES-DE/gamelists/xbox"
        if [ ! -f "$homeDir/ES-DE/gamelists/ps3/gamelist.xml" ]; then
          cat << 'GL_EOF' > "$homeDir/ES-DE/gamelists/ps3/gamelist.xml"
<?xml version="1.0"?>
<alternativeEmulator>
	<label>RPCS3 (Standalone)</label>
</alternativeEmulator>
<gameList />
GL_EOF
          chown -R ${cfgUser}:users "$homeDir/ES-DE/gamelists/ps3"
        fi

        if [ ! -f "$homeDir/ES-DE/gamelists/psx/gamelist.xml" ]; then
          cat << 'GL_EOF' > "$homeDir/ES-DE/gamelists/psx/gamelist.xml"
<?xml version="1.0"?>
<alternativeEmulator>
	<label>DuckStation (Standalone)</label>
</alternativeEmulator>
<gameList />
GL_EOF
          chown -R ${cfgUser}:users "$homeDir/ES-DE/gamelists/psx"
        fi

        if [ ! -f "$homeDir/ES-DE/gamelists/ps2/gamelist.xml" ]; then
          cat << 'GL_EOF' > "$homeDir/ES-DE/gamelists/ps2/gamelist.xml"
<?xml version="1.0"?>
<alternativeEmulator>
	<label>PCSX2 (Standalone)</label>
</alternativeEmulator>
<gameList />
GL_EOF
          chown -R ${cfgUser}:users "$homeDir/ES-DE/gamelists/ps2"
        fi

        if [ ! -f "$homeDir/ES-DE/gamelists/xbox/gamelist.xml" ]; then
          cat << 'GL_EOF' > "$homeDir/ES-DE/gamelists/xbox/gamelist.xml"
<?xml version="1.0"?>
<alternativeEmulator>
	<label>xemu (Standalone)</label>
</alternativeEmulator>
<gameList />
GL_EOF
          chown -R ${cfgUser}:users "$homeDir/ES-DE/gamelists/xbox"
        fi

        ${lib.optionalString cfg.retroarch.enable ''
          # Lien direct vers les cœurs RetroArch (SwanStation, Beetle PSX HW, etc.) pour ES-DE
          mkdir -p "$homeDir/.config/retroarch"
          ln -sfn "${retroarchWithCores}/lib/retroarch/cores" "$homeDir/.config/retroarch/cores"
          chown -R ${cfgUser}:users "$homeDir/.config/retroarch" || true
        ''}
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
