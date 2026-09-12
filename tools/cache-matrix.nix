# =============================================================================
# 🚀 ChomiamOS — Matrice Déclarative Complète des Dérivations pour le Cache
# Ce fichier recense l'intégralité des logiciels, émulateurs, suites de création,
# navigateurs et environnements de bureau disponibles dans ChomiamOS.
# =============================================================================

{ pkgs ? import <nixpkgs> { config.allowUnfree = true; }
, lib ? pkgs.lib
, inputs ? null
, self ? null
}:

let
  system = pkgs.stdenv.hostPlatform.system;

  # Source optionnelle pour nixpkgs-unstable avec support des paquets propriétaires (unfree)
  pkgs-unstable =
    if inputs ? nixpkgs-unstable
    then import inputs.nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true;
    }
    else pkgs;

  # 1. 🖥️ Environnements de Bureau (Toplevels NixOS complets)
  desktops = {
    gnome = if self != null && self ? nixosConfigurations.gnome
      then self.nixosConfigurations.gnome.config.system.build.toplevel
      else null;

    kde = if self != null && self ? nixosConfigurations.kde
      then self.nixosConfigurations.kde.config.system.build.toplevel
      else null;

    cosmic = if self != null && self ? nixosConfigurations.cosmic
      then self.nixosConfigurations.cosmic.config.system.build.toplevel
      else null;

    cinnamon = if self != null && self ? nixosConfigurations.cinnamon
      then self.nixosConfigurations.cinnamon.config.system.build.toplevel
      else null;

    full = if self != null && self ? nixosConfigurations.full
      then self.nixosConfigurations.full.config.system.build.toplevel
      else null;
  };

  # 2. 🎬 Montage Vidéo Professionnel (DaVinci Resolve)
  davinci = {
    free = pkgs.davinci-resolve;
    studio = pkgs.davinci-resolve-studio;
  };

  # 3. 🌐 Navigateurs Web
  browsers = {
    chrome = pkgs.google-chrome;
    firefox = pkgs.firefox;
    librewolf = pkgs.librewolf;
    brave = pkgs.brave;
  };

  # 4. 🕹️ Émulateurs & Retrogaming
  emulators = {
    duckstation =
      if inputs ? duckstation && inputs.duckstation ? packages.${system}.default
      then inputs.duckstation.packages.${system}.default
      else pkgs.duckstation;

    eden =
      if pkgs-unstable ? eden
      then pkgs-unstable.eden
      else null;

    dolphin = pkgs.dolphin-emu;
    pcsx2 = pkgs.pcsx2;
    ppsspp = pkgs.ppsspp;
    melonds = pkgs.melonds;
    mgba = pkgs.mgba;

    azahar =
      if pkgs-unstable ? azahar
      then pkgs-unstable.azahar
      else null;

    rpcs3 = pkgs.rpcs3;
    retroarch = pkgs.retroarch-full;
  };

  # 5. 🎨 Création 3D, Moteur de jeu & Multimédia
  creation = {
    blender =
      if pkgs-unstable ? blender
      then pkgs-unstable.blender
      else pkgs.blender;

    godot =
      if pkgs-unstable ? godot_4
      then pkgs-unstable.godot_4
      else pkgs.godot_4;

    kdenlive = pkgs.kdePackages.kdenlive;
    obsStudio = pkgs.obs-studio;
    audacity = pkgs.audacity;
    ardour = pkgs.ardour;
  };

  # 6. 🤖 Suite IA Locale
  aiSuite = {
    ollama = pkgs.ollama;
    openWebui = pkgs.open-webui;
    searxng = pkgs.searxng;
  };

  # 7. 🛠️ Outils Système & Gaming
  systemTools = {
    dashboard =
      if inputs ? chomiamos-dashboard && inputs.chomiamos-dashboard ? packages.${system}.default
      then inputs.chomiamos-dashboard.packages.${system}.default
      else null;

    wallpapers =
      if inputs ? chomiamos-wallpapers && inputs.chomiamos-wallpapers ? packages.${system}.default
      then inputs.chomiamos-wallpapers.packages.${system}.default
      else null;

    antigravity =
      if pkgs-unstable ? antigravity-ide
      then pkgs-unstable.antigravity-ide
      else null;

    pearDesktop =
      if pkgs-unstable ? pear-desktop
      then pkgs-unstable.pear-desktop
      else null;

    oversteer = pkgs.oversteer;
    steam = pkgs.steam;
    lutris = pkgs.lutris;
    heroic = pkgs.heroic;

    faugus =
      if pkgs-unstable ? faugus-launcher
      then pkgs-unstable.faugus-launcher
      else pkgs.faugus-launcher;

    virtManager = pkgs.virt-manager;
    tailscale = pkgs.tailscale;
    localsend = pkgs.localsend;
    motrix = pkgs.motrix;
    stremio = pkgs.stremio-linux-shell;
    vlc = pkgs.vlc;
    mpv = pkgs.mpv;
    goverlay = pkgs.goverlay;
  };

  # Helpers de filtrage des paquets non nuls
  validPkgs = attrs: lib.filter (p: p != null) (builtins.attrValues attrs);

  # Collections groupées
  allEmulators = pkgs.symlinkJoin {
    name = "chomiamos-emulators-bundle";
    paths = validPkgs emulators;
  };

  allCreation = pkgs.symlinkJoin {
    name = "chomiamos-creation-bundle";
    paths = validPkgs creation;
  };

  allBrowsers = pkgs.symlinkJoin {
    name = "chomiamos-browsers-bundle";
    paths = validPkgs browsers;
  };

  allSystemTools = pkgs.symlinkJoin {
    name = "chomiamos-tools-bundle";
    paths = validPkgs systemTools;
  };

  allAi = pkgs.symlinkJoin {
    name = "chomiamos-ai-bundle";
    paths = validPkgs aiSuite;
  };

  # Pack global hors DaVinci (pour préserver le quota 5 Go de Cachix)
  allPackages = pkgs.symlinkJoin {
    name = "chomiamos-all-packages-bundle";
    paths = (validPkgs emulators)
      ++ (validPkgs creation)
      ++ (validPkgs browsers)
      ++ (validPkgs systemTools)
      ++ (validPkgs aiSuite);
  };

in
{
  inherit desktops davinci browsers emulators creation aiSuite systemTools;
  inherit allEmulators allCreation allBrowsers allSystemTools allAi allPackages;
}
