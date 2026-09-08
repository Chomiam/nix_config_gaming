{ pkgs, vars, browserInfo, ... }:

{
  # =========================================================================
  # 🖥️ ENVIRONNEMENT DE BUREAU : GNOME SHELL
  # =========================================================================

  # Activation X11 & GDM & GNOME
  services.xserver.enable = true;
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # Exclusion de Xterm au niveau serveur d'affichage
  services.xserver.excludePackages = [ pkgs.xterm ];

  # Exclusions d'applications GNOME indésirables (Terminaux secondaires, applications inutiles)
  environment.gnome.excludePackages = with pkgs; [
    totem
    gnome-maps
    yelp
    gnome-tour
    epiphany
    gnome-console
  ];

  # Paquets GNOME & Extensions installés pour l'utilisateur principal
  users.users."${vars.user.username}".packages = with pkgs; [
    networkmanagerapplet
    gnome-tweaks
    gnome-extension-manager
    gnomeExtensions.dash-to-dock
    gnomeExtensions.blur-my-shell
    gnomeExtensions.appindicator
    gnomeExtensions.vitals
    gnomeExtensions.clipboard-indicator
    gnomeExtensions.arcmenu
  ];

  # Activation au niveau dconf système des extensions GNOME
  programs.dconf.profiles.user.databases = [
    {
      settings = {
        "org/gnome/shell" = {
          enabled-extensions = [
            "blur-my-shell@aunetx"
            "appindicatorsupport@rgcjonas.gmail.com"
            "Vitals@CoreCoding.com"
            "clipboard-indicator@tudmotu.com"
            "arcmenu@arcmenu.com"
          ];
        };
      };
    }
  ];

  # Paramètres Home-Manager pour l'utilisateur
  home-manager.users."${vars.user.username}" = { config, ... }: {
    # 1. Configuration des dossiers XDG standards en français
    xdg.userDirs = {
      enable = true;
      createDirectories = true;
      desktop = "${config.home.homeDirectory}/Bureau";
      documents = "${config.home.homeDirectory}/Documents";
      download = "${config.home.homeDirectory}/Téléchargements";
      music = "${config.home.homeDirectory}/Musique";
      pictures = "${config.home.homeDirectory}/Images";
      publicShare = "${config.home.homeDirectory}/Public";
      templates = "${config.home.homeDirectory}/Modèles";
      videos = "${config.home.homeDirectory}/Vidéos";
      extraConfig = {
        XDG_PROJECTS_DIR = "${config.home.homeDirectory}/Projets";
      };
    };

    # 2. Déposer automatiquement des modèles dans le dossier de modèles
    home.file."Modèles/Nouveau document.txt".text = "";
    home.file."Modèles/script.sh" = {
      text = "";
      executable = true;
    };
    home.file."Modèles/Document.docx".source = ./templates/Document.docx;
    home.file."Modèles/Tableur.xlsx".source = ./templates/Tableur.xlsx;
    home.file."Modèles/Presentation.pptx".source = ./templates/Presentation.pptx;

    dconf.settings = {
      "org/gnome/shell" = {
        favorite-apps = [
          "kitty.desktop"
          "org.gnome.Settings.desktop"
          "org.gnome.Nautilus.desktop"
          "io.github.kolunmi.Bazaar.desktop"
          browserInfo.desktopFile
          "discord.desktop"
          "steam.desktop"
          "net.lutris.Lutris.desktop"
          "com.heroicgameslauncher.hgl.desktop"
        ] ++ pkgs.lib.optionals (vars.gaming.geforceNow or true) [
          "com.nvidia.geforcenow.desktop"
        ] ++ [
          "onlyoffice-desktopeditors.desktop"
          "thunderbird.desktop"
          "com.obsproject.Studio.desktop"
        ];
      };

      "org/gnome/mutter" = {
        experimental-features = [
          "scale-monitor-framebuffer"
          "xwayland-native-scaling"
          "hdr"
        ];
      };

      "org/gnome/desktop/interface" = {
        accent-color = "purple";
        color-scheme = "prefer-dark";
      };

      "org/gnome/shell/extensions/dash-to-dock" = {
        dock-position = "LEFT";
        dock-fixed = true;
        extend-height = true;
        dash-max-icon-size = 48;
      };
    };
  };
}
