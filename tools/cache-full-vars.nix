# =============================================================================
# 🚀 ChomiamOS — Variables pour Configuration Complète / Cache Intégral
# Utilisé par flake.nix (nixosConfigurations.full) pour évaluer et compiler
# toutes les fonctionnalités, émulateurs, outils de création et services.
# =============================================================================

{
  # Virtualisation KVM / QEMU / Virt-Manager
  virtualisation = {
    enable = true;
  };

  # Suite Gaming complète
  gaming = {
    enable = true;
    gamescopeSession = true;
    launchers = {
      steam = true;
      lutris = true;
      heroic = true;
      faugus = true;
    };
    deckyLoader = true;
    geforceNow = true;
    mountGamesDisk = true;
    sunshine = true;
    sober = true;
  };

  # Suite d'Émulation & Rétrogaming intégrale
  emulation = {
    enable = true;
    frontend = "es-de";
    autoCheckUpdates = true;

    retroarch = {
      enable = true;
    };

    standalone = {
      duckstation = true;
      eden = true;
      dolphin = true;
      pcsx2 = true;
      ppsspp = true;
      melonds = true;
      mgba = true;
      azahar = true;
      rpcs3 = true;
      xemu = true;
      cemu = true;
      xenia-canary = true;
    };
  };

  # Volants & Périphériques Simracing (Oversteer)
  steeringWheelSupport = true;

  # Montage Vidéo DaVinci Resolve (version gratuite par défaut pour le cache)
  davinciResolve = "free";

  # Création 3D & Moteur de jeu
  blender = true;
  godot = true;

  # Applications Réseau, Téléchargement & Multimédia
  tailscale = true;
  localsend = true;
  motrix = true;
  stremio = true;
  vlc = true;
  mpv = true;

  # Productivité, Outils & Création Audio/Vidéo
  ide = {
    zed = true;
    antigravity = true;
    vscode = true;
  };
  antigravity = true;
  zed = true;
  vscode = true;
  pearDesktop = true;
  kdenlive = true;
  obsStudio = true;
  goverlay = true;
  flatseal = true;
  audacity = true;
  ardour = true;

  # Impression 3D (Slicers)
  slicers = {
    orcaslicer = true;
    prusaslicer = true;
    cura = true;
    bambustudio = true;
  };

  # Suite IA locale (Open WebUI, Ollama & Agent IA Hermes)
  iaSuite = {
    enable = true;
    openFirewall = false;
    ollama = {
      enable = true;
      port = 11434;
      acceleration = "auto";
      rocmOverrideGfx = null;
      models = [ ];
    };
    openWebUI = {
      enable = true;
      port = 8080;
    };
    hermes = {
      enable = true;
      apiPort = 8642;
      dashboardPort = 9119;
      defaultModel = "hermes3";
    };
  };
}
