{
  # =========================================================================
  # ⚙️ VARIABLES DU SYSTÈME CHOMIAMOS GAMING EDITION
  # Ce fichier contient les personnalisations locales de votre machine.
  # Modifié via le Dashboard ChomiamOS ou manuellement.
  # Les variables non définies ici héritent automatiquement de vars-defaults.nix.
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
    fullName = "ChomiamOS User";
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
    enable = false;
  };

  # Navigateur web principal
  # Options disponibles : "chrome" | "firefox" | "brave" | "zen" | "librewolf"
  browser = "chrome";

  # Émulateur de terminal principal
  # Options disponibles : "kitty" | "gnome-terminal" | "konsole" | "alacritty" | "cosmic-term"
  terminal = "kitty";

  # Mode d'installation du navigateur : "system" (Nix) | "flatpak" (Flathub)
  # Note : Zen et LibreWolf sont gérés exclusivement via Flatpak.
  browserPackageType = "system";

  # Client de messagerie e-mail
  # Options disponibles : "thunderbird" | "mailspring" | "none"
  mailClient = "thunderbird";

  # Client Discord
  discordClient = "discord";

  # Pare-feu réseau
  firewall = false;

  # Environnement de bureau
  # Options disponibles : "gnome" | "cosmic" | "cinnamon" | "kde" | "budgie"
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
      faugus = true;
    };
    deckyLoader = false;
    geforceNow = true;
    mountGamesDisk = true;
    sunshine = false;
    sober = false;
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
      xemu = false;
      cemu = false;
      xenia-canary = false;
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
  openssh = true;
  localsend = true;
  motrix = true;

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
  goverlay = true;
  flatseal = true;
  audacity = false;
  ardour = false;

  # Impression 3D & Slicers
  slicers = {
    orcaslicer = false;
    prusaslicer = false;
    cura = false;
    bambustudio = false;
  };

  # Service d'inférence LLM local Ollama pour l'autocomplétion de code dans Neovim
  ollama = {
    enable = false;
    acceleration = "auto";
    rocmOverrideGfx = null;
    model = "qwen2.5-coder:7b";
    systemPrompt = null;
    port = 11434;
    aichat = false;
    lmstudio = false;
  };

  # Pilote Playwright & Chromium pour agents IA (agent-browser, automatisation)
  playwright = false;
}
