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

  # Disposition du clavier
  keyboard = {
    layout = "fr";
    variant = "";
    keyMap = "fr";
  };

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
      "podman"
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
  discordClient = "vesktop";

  # Pare-feu réseau
  firewall = false;

  # Environnement de bureau
  desktopEnv = "gnome";

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
    sunshine = false;
    sober = false;
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
      xemu = true;
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

  # Environnements de Développement & IDEs (Choix multiple)
  ide = {
    zed = true;
    antigravity = true;
    vscode = false;
  };
  antigravity = true;
  zed = true;
  vscode = false;
  pearDesktop = true;
  kdenlive = false;
  obsStudio = true;

  # Suite IA locale complète (Open WebUI, Ollama accéléré par GPU, Agent IA Hermes)
  # Interfaces : Open WebUI sur http://localhost:8080, Hermes Dashboard sur http://localhost:9119
  iaSuite = {
    enable = true;
  };
}
