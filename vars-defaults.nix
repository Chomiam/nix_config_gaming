{
  # =========================================================================
  # ⚙️ VARIABLES PAR DÉFAUT — CHOMIAMOS GAMING EDITION
  # =========================================================================
  # Ce fichier est le schéma de référence de toutes les variables disponibles.
  # Il est tracké par Git et mis à jour automatiquement lors d'un 'git pull'.
  #
  # ⚠️ NE PAS MODIFIER CE FICHIER MANUELLEMENT !
  # Les personnalisations se font dans vars.nix (protégé par merge=ours).
  #
  # Fonctionnement :
  #   1. vars-defaults.nix fournit TOUTES les variables avec des valeurs sûres
  #   2. vars.nix contient les personnalisations de chaque utilisateur
  #   3. Le flake.nix fusionne les deux : vars.nix écrase vars-defaults.nix
  #   4. Les nouvelles variables ajoutées ici arrivent automatiquement chez tous
  # =========================================================================

  # Nom d'hôte de la machine (Hostname)
  hostName = "chomiamos";

  # Localisation & Fuseau horaire
  timeZone = "Europe/Paris";
  defaultLocale = "fr_FR.UTF-8";

  # Version de l'état système NixOS / Home Manager
  stateVersion = "26.05";

  # Profil utilisateur principal
  user = {
    username = "chomiam";
    fullName = "ChomiamOS User";
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
    enable = false;
  };

  # Navigateur web principal
  browser = "chrome";

  # Client Discord
  discordClient = "discord";

  # Pare-feu réseau
  firewall = false;

  # Environnement de bureau
  desktopEnv = "gnome";

  # Matériel GPU
  gpuDriver = "amd";

  # Options du mode Gaming
  gaming = {
    enable = true;
    gamescopeSession = true;
    launchers = {
      steam = true;
      lutris = true;
      heroic = true;
      faugus = true;
    };
    deckyLoader = false;
    geforceNow = true;
    mountGamesDisk = true;
  };

  # Suite d'Émulation & Rétrogaming
  emulation = {
    enable = false;
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
  steeringWheelSupport = true;

  # Montage vidéo DaVinci Resolve
  davinciResolve = "none";

  # Logiciels de Création 3D & Moteur de jeu
  blender = false;
  godot = false;

  # Applications Réseau & Partage
  tailscale = true;
  localsend = true;
  motrix = true;

  # Multimédia & Streaming
  stremio = true;
  vlc = true;
  mpv = true;

  # Productivité & Outils
  antigravity = true;
  pearDesktop = true;
  kdenlive = false;
  obsStudio = true;
  goverlay = true;
  flatseal = true;
  audacity = false;
  ardour = false;

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
