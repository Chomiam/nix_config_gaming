{
  # =========================================================================
  # ⚙️ VARIABLES DU SYSTÈME CHOMIAMOS GAMING EDITION
  # Modifié via le Dashboard ChomiamOS
  # =========================================================================

  # Nom d'hôte de la machine (Hostname)
  hostName = "chomiamos";

  # Localisation & Fuseau horaire
  timeZone = "Europe/Paris";
  defaultLocale = "fr_FR.UTF-8";

  # Version de l'état système NixOS / Home Manager
  stateVersion = "26.05";

  # Profil utilisateur principal (Préservé automatiquement)
  user = {
    username = "chomiam";
    fullName = "Axel Valens";
    homeDirectory = "/home/chomiam";
    shell = "fish";
    initialHashedPassword = null;
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
      "video"
    ];
  };

  # Virtualisation
  virtualisation = {
    enable = true;
  };

  # Navigateur web principal
  browser = "chrome";

  # Client Discord
  discordClient = "discord";

  # Pare-feu réseau
  firewall = false;

  # Environnement de bureau
  desktopEnv = "cinnamon";

  # Matériel GPU (Préservé automatiquement)
  gpuDriver = "amd";

  # Options du mode Gaming
  gaming = {
    enable = true;
    gamescopeSession = true;
    launchers = {
      steam = true;
      lutris = true;
      heroic = true;
      faugus = false;
    };
    deckyLoader = true;
    geforceNow = false;
    mountGamesDisk = true;
  };

  # Suite d'Émulation & Rétrogaming
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
      rpcs3 = false;
    };
  };

  # Volants & Simracing
  steeringWheelSupport = false;

  # Montage vidéo DaVinci Resolve
  davinciResolve = "none";

  # Logiciels de Création 3D & Moteur de jeu
  blender = true;
  godot = true;

  # Applications Réseau & Partage
  tailscale = false;
  flatseal = true;
  goverlay = true;
  audacity = false;
  ardour = false;
  localsend = true;
  motrix = false;

  # Impression 3D & Slicers
  slicers = {
    orcaslicer = false;
    prusaslicer = false;
    cura = false;
    bambustudio = false;
  };

  # Multimédia & Streaming
  stremio = true;
  vlc = true;
  mpv = true;

  # Productivité & Outils
  antigravity = true;
  pearDesktop = true;
  kdenlive = false;
  obsStudio = true;

  # Suite IA Locale
  aiSuite = {
    enable = false;
    rocmOverrideGfx = "12.0.1";
    keepAlive = "0s";
    openWebUiPort = 8080;
    searxPort = 8888;
    openFirewall = false;
  };
}
