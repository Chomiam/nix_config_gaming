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
    [ pkgs-unstable.eden ]
    ++ standalonePackages
    ++ lib.optional cfg.retroarch.enable retroarchWithCores
  );

  # Frontend ES-DE enveloppé avec le PATH des émulateurs
  es-de = pkgs.symlinkJoin {
    name = "es-de-${es-de-base.version}";
    paths = [ es-de-base ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/es-de \
        --prefix PATH : "${emulatorsPath}"
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
    ++ lib.optional (cfg.standalone.rpcs3) pkgs-unstable.rpcs3;

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

    # 3. Création déclarative de l'arborescence des ROMs et BIOS
    system.activationScripts.emulationDirs = lib.stringAfter [ "users" ] ''
      homeDir="/home/${cfgUser}"
      if [ -d "$homeDir" ]; then
        romsDir="$homeDir/Jeux/ROMs"
        biosDir="$homeDir/Jeux/BIOS"
        mkdir -p "$romsDir"/{snes,megadrive,nes,gba,gbc,gb,n64,nds,n3ds,gamecube,wii,switch,psx,ps2,psp,arcade} "$biosDir"
        ln -sfn "$romsDir/n3ds" "$romsDir/3ds"
        chown -R ${cfgUser}:users "$homeDir/Jeux"
        chmod -R u+rwX,g+rwX "$homeDir/Jeux"

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

        # 4. Configuration déclarative d'ES-DE : DuckStation (PSX) et PCSX2 (PS2) par défaut
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
</systemList>
CUSTOM_SYS_EOF
        chown -R ${cfgUser}:users "$homeDir/ES-DE/custom_systems"

        # Initialisation déclarative des alternativeEmulator dans les gamelists ES-DE
        mkdir -p "$homeDir/ES-DE/gamelists/ps2" "$homeDir/ES-DE/gamelists/psx"
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
