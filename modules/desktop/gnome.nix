{ config, lib, pkgs, browserInfo, ... }:

let
  cfg = config.chomiamos;
  enableGnome = cfg.desktop.env == "gnome" || cfg.desktop.env == "both";
  username = cfg.user.username;
in
{
  # =========================================================================
  # 🖥️ ENVIRONNEMENT DE BUREAU : GNOME SHELL
  # =========================================================================

  config = lib.mkIf enableGnome {
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
    users.users."${username}".packages = with pkgs; [
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

    # Déploiement du fond d'écran officiel par défaut
    environment.etc."backgrounds/chomiamos/wallpaper.jpeg".source = ../../assets/wallpaper.jpeg;

    # Activation au niveau dconf système des extensions et du fond d'écran GNOME
    programs.dconf.profiles.user.databases = [
      {
        settings = {
          "org/gnome/shell" = {
            enabled-extensions = [
              "appindicatorsupport@rgcjonas.gmail.com"
              "Vitals@CoreCoding.com"
              "clipboard-indicator@tudmotu.com"
              "arcmenu@arcmenu.com"
              "blur-my-shell@aunetx"
              "dash-to-dock@micxgx.gmail.com"
            ];
          };

          "org/gnome/desktop/background" = {
            picture-uri = "file:///etc/backgrounds/chomiamos/wallpaper.jpeg";
            picture-uri-dark = "file:///etc/backgrounds/chomiamos/wallpaper.jpeg";
            picture-options = "zoom";
          };

          "org/gnome/desktop/screensaver" = {
            picture-uri = "file:///etc/backgrounds/chomiamos/wallpaper.jpeg";
            picture-options = "zoom";
          };
        };
      }
    ];

    # Paramètres Home-Manager pour l'utilisateur
    home-manager.users."${username}" = { config, ... }: {
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
          enabled-extensions = [
            "appindicatorsupport@rgcjonas.gmail.com"
            "Vitals@CoreCoding.com"
            "clipboard-indicator@tudmotu.com"
            "arcmenu@arcmenu.com"
            "blur-my-shell@aunetx"
            "dash-to-dock@micxgx.gmail.com"
          ];

          favorite-apps = [
            "kitty.desktop"
            "org.gnome.Settings.desktop"
            "org.gnome.Nautilus.desktop"
            "io.github.kolunmi.Bazaar.desktop"
            browserInfo.desktopFile
            "discord.desktop"
          ] ++ pkgs.lib.optionals cfg.gaming.launchers.steam [
            "steam.desktop"
          ] ++ pkgs.lib.optionals cfg.gaming.launchers.lutris [
            "net.lutris.Lutris.desktop"
          ] ++ pkgs.lib.optionals cfg.gaming.launchers.heroic [
            "com.heroicgameslauncher.hgl.desktop"
          ] ++ pkgs.lib.optionals cfg.gaming.launchers.faugus [
            "faugus-launcher.desktop"
          ] ++ pkgs.lib.optionals cfg.gaming.geforceNow [
            "com.nvidia.geforcenow.desktop"
          ] ++ [
            "onlyoffice-desktopeditors.desktop"
            "thunderbird.desktop"
            "com.obsproject.Studio.desktop"
          ];
        };

        "org/gnome/desktop/wm/preferences" = {
          button-layout = "icon:minimize,maximize,close";
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
          gtk-theme = "adw-gtk3-dark";
          icon-theme = "Papirus-Dark";
        };

        "org/gnome/desktop/background" = {
          picture-uri = "file:///etc/backgrounds/chomiamos/wallpaper.jpeg";
          picture-uri-dark = "file:///etc/backgrounds/chomiamos/wallpaper.jpeg";
          picture-options = "zoom";
        };

        "org/gnome/desktop/screensaver" = {
          picture-uri = "file:///etc/backgrounds/chomiamos/wallpaper.jpeg";
          picture-options = "zoom";
        };

        "org/gnome/shell/extensions/dash-to-dock" = {
          dock-position = "LEFT";
          dock-fixed = true;
          extend-height = true;
          dash-max-icon-size = 48;
          height-fraction = lib.gvariant.mkDouble 0.9;
          background-opacity = lib.gvariant.mkDouble 0.8;
          custom-theme-shrink = true;
          hide-tooltip = false;
          preferred-monitor = -2;
          show-icons-notifications-counter = false;
          show-show-apps-button = false;
        };

        "org/gnome/shell/extensions/arcmenu" = {
          menu-button-appearance = "None";
          menu-layout = "runner";
          prefs-visible-page = 0;
          search-entry-border-radius = lib.gvariant.mkTuple [ (lib.gvariant.mkBoolean true) (lib.gvariant.mkInt32 25) ];
          update-notifier-project-version = 73;
        };

        "org/gnome/shell/extensions/blur-my-shell" = {
          settings-version = 2;
        };

        "org/gnome/shell/extensions/blur-my-shell/appfolder" = {
          brightness = lib.gvariant.mkDouble 0.6;
          sigma = 30;
        };

        "org/gnome/shell/extensions/blur-my-shell/applications" = {
          blur = true;
          blur-on-overview = true;
          dynamic-opacity = false;
          enable-all = false;
          pipeline = "pipeline_default";
          sigma = 30;
          static-blur = false;
          whitelist = [ "org.gnome.Nautilus" ];
        };

        "org/gnome/shell/extensions/blur-my-shell/dash-to-dock" = {
          blur = true;
          brightness = lib.gvariant.mkDouble 0.6;
          pipeline = "pipeline_default_rounded";
          sigma = 30;
          static-blur = true;
          style-dash-to-dock = 0;
        };

        "org/gnome/shell/extensions/blur-my-shell/panel" = {
          brightness = lib.gvariant.mkDouble 0.6;
          corner-radius = 0;
          pipeline = "pipeline_default";
          sigma = 30;
        };

        "org/gnome/shell/extensions/blur-my-shell/window-list" = {
          brightness = lib.gvariant.mkDouble 0.6;
          sigma = 30;
        };
      };
    };
  };
}
