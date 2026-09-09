{
  # =========================================================================
  # ⚙️ VARIABLES CENTRALISÉES DU SYSTÈME ET DE L'UTILISATEUR
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

  # =========================================================================
  # 🖥️ VIRTUALISATION (VIRT-MANAGER, KVM / QEMU, LIBVIRT)
  # Options disponibles : true | false
  #
  # - true  : Active libvirtd, Virt-Manager, les pilotes VirtIO
  #           (dont virtio-win compatible Windows 7), SPICE et virbr0.
  # - false : Désactivé (Aucun service ni paquet de virtualisation chargé).
  # =========================================================================
  virtualisation = {
    enable = true;
  };

  # =========================================================================
  # 🌐 SELECTION DU NAVIGATEUR WEB PRINCIPAL
  # Options disponibles : "chrome" | "firefox" | "zen" | "librewolf" | "opera" | "opera-gx"
  #
  # - "chrome"    : Google Chrome (Paquet Nix)
  # - "firefox"   : Mozilla Firefox (Paquet Nix)
  # - "librewolf" : LibreWolf (Paquet Nix orienté respect de la vie privée)
  # - "opera"     : Opera Browser (Flatpak Flathub : com.opera.Opera)
  # - "opera-gx"  : Opera GX (Flatpak Flathub : com.opera.opera-gx)
  # - "zen"       : Zen Browser (Flatpak Flathub : app.zen_browser.zen)
  # =========================================================================
  browser = "chrome";

  # =========================================================================
  # 💬 CLIENT DE COMMUNICATION DISCORD
  # Options disponibles : "discord" | "equibop" | "vesktop" | "none"
  #
  # - "discord" : Client officiel Discord (Paquet Nix natif)
  # - "equibop" : Client Equibop (Flatpak Flathub : io.github.equicord.equibop)
  # - "vesktop" : Client Vesktop Vencord (Flatpak Flathub : dev.vencord.Vesktop)
  # - "none"    : Aucun client Discord installé
  # =========================================================================
  discordClient = "discord";


  # =========================================================================
  # 🛡️ PARE-FEU RÉSEAU (FIREWALL)
  # Options disponibles : true | false
  #
  # - true  : Active le pare-feu système et ses règles de filtrage.
  # - false : Désactive le pare-feu système.
  # =========================================================================
  firewall = false;

  # =========================================================================
  # 🖥️ ENVIRONNEMENT DE BUREAU
  # Options disponibles : "gnome" | "cosmic" | "both"
  # =========================================================================
  desktopEnv = "gnome";

  # =========================================================================
  # 🎮 SELECTION MATÉRIELLE (GPU)
  # Options disponibles : "amd" | "nvidia" | "nvidia-legacy" | "intel"
  #
  # - "amd"           : AMD Radeon (RADV Vulkan, ROCm OpenCL, Kernel XanMod Latest)
  # - "nvidia"        : NVIDIA Moderne (GTX 1650 / RTX et plus récentes) (Drivers récents + Kernel XanMod Stable)
  # - "nvidia-legacy" : NVIDIA Ancienne génération (< GTX 1650 : GTX 10xx, 9xx, etc.) (Pilotes legacy 470/390 + Kernel XanMod Stable)
  # - "intel"         : Intel iGPU/dGPU (VAAPI intel-media-driver, Kernel XanMod Latest)
  # =========================================================================
  gpuDriver = "amd";

  # Options du mode Gaming
  gaming = {
    enable = true;
    launchers = {
      steam = true;
      lutris = true;
      heroic = true;
      faugus = true;
    };
    deckyLoader = true;
    geforceNow = true;
    mountGamesDisk = true;
  };

  # =========================================================================
  # 🏎️ PRISE EN CHARGE DES VOLANTS & PERIPHERIQUES DE SIMRACING (OVERSTEER)
  # Options disponibles : true | false
  #
  # - true  : Active les drivers noyau supplémentaires (new-lg4ff, hid-fanatecff,
  #           hid-tmff2, hid-t150, universal-pidff), les règles udev et l'app Oversteer.
  # - false : Désactivé (Aucun pilote ni logiciel supplémentaire chargé).
  # =========================================================================
  steeringWheelSupport = true;

  # =========================================================================
  # 🎬 LOGICIEL DE MONTAGE DAVINCI RESOLVE
  # Options disponibles : "none" | "free" | "studio"
  #
  # - "none"   : Désactivé (Aucun paquet ni dépendance OpenCL/ROCm inutile installée)
  # - "free"   : Version Gratuite (DaVinci Resolve) + Accélération GPU selon vars.gpuDriver
  # - "studio" : Version Payante (DaVinci Resolve Studio) + Accélération GPU selon vars.gpuDriver
  # =========================================================================
  davinciResolve = "none";

  # =========================================================================
  # 🎨 LOGICIELS DE CRÉATION 3D & MOTEURS DE JEU (BLENDER & GODOT ENGINE)
  # Options disponibles : true | false
  #
  # - blender : Active l'installation de Blender 3D (tiré de nixpkgs-unstable).
  # - godot   : Active l'installation de Godot Engine (tiré de nixpkgs-unstable).
  # =========================================================================
  blender = true;
  godot = true;

  # =========================================================================
  # 🌐 APPLICATIONS RÉSEAU, PARTAGE & TÉLÉCHARGEMENT
  # =========================================================================
  tailscale = true;
  localsend = true;
  motrix = true;

  # =========================================================================
  # 📺 MULTIMÉDIA & STREAMING
  # =========================================================================
  stremio = true;
  vlc = true;
  mpv = true;

  # =========================================================================
  # 💻 PRODUCTIVITÉ & OUTILS
  # =========================================================================
  antigravity = true;
  pearDesktop = true;
  kdenlive = true;


  # =========================================================================
  # 🤖 SUITE IA LOCALE (OLLAMA + OPEN-WEBUI + SEARXNG)
  # =========================================================================
  aiSuite = {
    # Active la suite complète Ollama + Open-WebUI + SearXNG (Désactivé par défaut)
    enable = false;

    # Override ROCm spécifique aux GPU AMD (ex: "12.0.1" pour RX 9070 XT RDNA4, "11.0.0" pour RX 7000 RDNA3, "10.3.0" pour RX 6000).
    # NOTE : Cette variable est automatiquement ignorée si vars.gpuDriver est réglé sur "nvidia", "nvidia-legacy" ou "intel".
    rocmOverrideGfx = "12.0.1";

    # Libération instantanée de la VRAM (0s = déchargement immédiat du modèle après génération)
    keepAlive = "0s";

    # Ports des services locaux
    openWebUiPort = 8080;
    searxPort = 8888;
  };
}
