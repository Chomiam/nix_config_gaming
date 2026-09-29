{ config, lib, pkgs, browserInfo, ... }:

let
  cfg = config.chomiamos;
  enableGnome = cfg.desktop.env == "gnome" || cfg.desktop.env == "both";
  username = cfg.user.username;

  # Types MIME d'images associés par défaut à Loupe
  imageMimeTypes = [
    "image/apng"
    "image/avif"
    "image/bmp"
    "image/gif"
    "image/heic"
    "image/heif"
    "image/jpeg"
    "image/jpg"
    "image/jxl"
    "image/png"
    "image/svg+xml"
    "image/svg+xml-compressed"
    "image/tiff"
    "image/vnd.microsoft.icon"
    "image/webp"
    "image/x-bmp"
    "image/x-gray"
    "image/x-icb"
    "image/x-ico"
    "image/x-png"
    "image/x-portable-anymap"
    "image/x-portable-bitmap"
    "image/x-portable-graymap"
    "image/x-portable-pixmap"
    "image/x-tga"
    "image/x-xbitmap"
    "image/x-xpixmap"
  ];
  imageMimeAssociations = lib.genAttrs imageMimeTypes (_: "org.gnome.Loupe.desktop");
  imageMimeAssociationsList = lib.genAttrs imageMimeTypes (_: [ "org.gnome.Loupe.desktop" ]);
in
{
  # =========================================================================
  # 🖥️ ENVIRONNEMENT DE BUREAU : GNOME SHELL
  # =========================================================================

  config = lib.mkIf enableGnome {
    # Association par défaut de Loupe pour l'ouverture des images
    xdg.mime.defaultApplications = imageMimeAssociations;

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

    # Paquet système Loupe
    environment.systemPackages = [
      pkgs.loupe
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
      gnomeExtensions.user-themes
      gnomeExtensions.no-overview
      loupe
    ];

    # Paramètres Home-Manager pour l'utilisateur
    home-manager.users."${username}" = { config, ... }: {
      # Association MIME pour l'utilisateur
      xdg.mimeApps = {
        enable = true;
        defaultApplications = imageMimeAssociationsList;
      };

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
    };
  };
}
