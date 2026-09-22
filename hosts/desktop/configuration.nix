{ config, pkgs, lib, inputs, vars, ... }:

{
  # =========================================================================
  # 🖥️ HÔTE DESKTOP : ASSEMBLAGE MODULAIRE CHOMIAMOS
  # =========================================================================

  imports = [
    # Configuration matérielle spécifique à cette machine
    ./hardware-configuration.nix
    ./mount.nix

    # Architecture modulaire chomiamos
    ../../modules
  ];
nixpkgs.config.allowUnfree = true;
  # =========================================================================
  # ⚙️ CONFIGURATION DES OPTIONS DU SYSTÈME (ALIMENTÉE PAR VARS.NIX)
  # =========================================================================
  chomiamos = {
    hostName = vars.hostName;
    timeZone = vars.timeZone;
    defaultLocale = vars.defaultLocale;
    stateVersion = vars.stateVersion;

    keyboard = {
      layout = vars.keyboard.layout or "fr";
      variant = vars.keyboard.variant or "";
      keyMap = vars.keyboard.keyMap or "fr";
    };

    user = {
      username = vars.user.username;
      fullName = vars.user.fullName;
      homeDirectory = vars.user.homeDirectory;
      shell = vars.user.shell;
      extraGroups = vars.user.extraGroups;
      initialHashedPassword = vars.user.initialHashedPassword or null;
    };

    firewall.enable = if builtins.isBool (vars.firewall or false) then vars.firewall else (vars.firewall.enable or false);

    hardware = {
      gpu = vars.gpuDriver;
      steeringWheels.enable = vars.steeringWheelSupport or true;
    };

    desktop = {
      env = vars.desktopEnv;
    };

    browser = vars.browser;
    browserPackageType = vars.browserPackageType or "system";
    mailClient = vars.mailClient or "thunderbird";
    discordClient = vars.discordClient or "discord";

    gaming = {
      enable = vars.gaming.enable or true;
      launchers = {
        steam = vars.gaming.launchers.steam or true;
        lutris = vars.gaming.launchers.lutris or true;
        heroic = vars.gaming.launchers.heroic or true;
        faugus = vars.gaming.launchers.faugus or true;
      };
      deckyLoader = vars.gaming.deckyLoader or false;
      geforceNow = vars.gaming.geforceNow or true;
      gamescopeSession = vars.gaming.gamescopeSession or (vars.gpuDriver != "nvidia" && vars.gpuDriver != "nvidia-legacy");
      mountGamesDisk = vars.gaming.mountGamesDisk or true;
      sunshine = vars.gaming.sunshine or false;
      sober = vars.gaming.sober or false;
    };

    emulation = {
      enable = vars.emulation.enable or false;
      frontend = vars.emulation.frontend or "es-de";
      romsDir = vars.emulation.romsDir or "/mnt/Emudeck/Emulation/roms";
      biosDir = vars.emulation.biosDir or "/mnt/Emudeck/Emulation/bios";
      es-de = {
        enable = vars.emulation.esDe or vars.emulation.es-de or (vars.emulation.enable or false);
        autoCheckUpdates = vars.emulation.autoCheckUpdates or true;
      };
      retroarch = {
        enable = vars.emulation.retroarch.enable or (vars.emulation.enable or false);
      };
      retroachievements = {
        enable = vars.emulation.retroachievements.enable or (vars.emulation.esDe or vars.emulation.es-de or (vars.emulation.enable or false));
      };
      standalone = {
        duckstation = vars.emulation.standalone.duckstation or true;
        eden = vars.emulation.standalone.eden or true;
        dolphin = vars.emulation.standalone.dolphin or true;
        pcsx2 = vars.emulation.standalone.pcsx2 or true;
        ppsspp = vars.emulation.standalone.ppsspp or true;
        melonds = vars.emulation.standalone.melonds or true;
        mgba = vars.emulation.standalone.mgba or true;
        azahar = vars.emulation.standalone.azahar or true;
        rpcs3 = vars.emulation.standalone.rpcs3 or false;
        xemu = vars.emulation.standalone.xemu or false;
        cemu = vars.emulation.standalone.cemu or false;
        xenia-canary = vars.emulation.standalone.xenia-canary or vars.emulation.standalone.xeniaCanary or vars.emulation.standalone.xenia or false;
      };
    };

    services = {
      virtualisation.enable = vars.virtualisation.enable or false;
      samba.enable = true;
      podman.enable = true;
      nix-ld.enable = true;
      flatpak.enable = true;
      obs.enable = vars.obsStudio or true;
      neovim.enable = true;
      blender.enable = vars.blender or false;
      godot.enable = vars.godot or false;
      tailscale.enable = vars.tailscale or true;
      openssh.enable = vars.openssh or vars.ssh or true;
      localsend.enable = vars.localsend or true;
      motrix.enable = vars.motrix or true;
      stremio.enable = vars.stremio or true;
      vlc.enable = vars.vlc or true;
      mpv.enable = vars.mpv or true;
      antigravity.enable = vars.ide.antigravity or vars.antigravity or true;
      zed.enable = vars.ide.zed or vars.zed or false;
      vscode.enable = vars.ide.vscode or vars.vscode or false;
      pearDesktop.enable = vars.pearDesktop or true;
      kdenlive.enable = vars.kdenlive or false;
      goverlay.enable = vars.goverlay or true;
      flatseal.enable = vars.flatseal or true;
      audacity.enable = vars.audacity or false;
      ardour.enable = vars.ardour or false;
      davinciResolve.version = vars.davinciResolve or "none";

      slicers = {
        orcaslicer.enable = vars.slicers.orcaslicer or false;
        prusaslicer.enable = vars.slicers.prusaslicer or false;
        cura.enable = vars.slicers.cura or false;
        bambustudio.enable = vars.slicers.bambustudio or false;
      };

      iaSuite = let
        iaVars = vars.iaSuite or vars."ia-suite" or vars.aiSuite or vars."ai-suite" or {};
        llamaVars = iaVars.llamaCpp or iaVars.llama-cpp or iaVars.ollama or {};
        webUiVars = iaVars.openWebUI or iaVars.openWebUi or {};
        hermesVars = iaVars.hermes or {};
      in {
        enable = iaVars.enable or false;
        openFirewall = iaVars.openFirewall or false;
        llamaCpp = {
          enable = llamaVars.enable or true;
          port = llamaVars.port or 11434;
          acceleration = llamaVars.acceleration or "auto";
          rocmOverrideGfx = llamaVars.rocmOverrideGfx or iaVars.rocmOverrideGfx or null;
          model = llamaVars.model or null;
          modelsDir = llamaVars.modelsDir or null;
          modelsPreset = llamaVars.modelsPreset or null;
          hfRepo = llamaVars.hfRepo or null;
          hfFile = llamaVars.hfFile or null;
          contextLength = llamaVars.contextLength or 131072;
          contextShift = llamaVars.contextShift or false;
          gpuLayers = llamaVars.gpuLayers or 99;
          apiKey = llamaVars.apiKey or null;
          alias = llamaVars.alias or null;
          extraFlags = llamaVars.extraFlags or [ ];
        };
        openWebUI = {
          enable = webUiVars.enable or true;
          port = webUiVars.port or iaVars.openWebUiPort or 8085;
        };
        hermes = {
          enable = hermesVars.enable or true;
          apiPort = hermesVars.apiPort or 8642;
          dashboardPort = hermesVars.dashboardPort or 9119;
          dashboardUsername = hermesVars.dashboardUsername or "admin";
          dashboardPassword = hermesVars.dashboardPassword or "admin";
          apiKey = hermesVars.apiKey or "hermes-agent-key";
          defaultModel = hermesVars.defaultModel or null;
        };
      };
    };
  };
}
