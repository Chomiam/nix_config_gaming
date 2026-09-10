{ config, lib, pkgs, browserInfo, ... }:

let
  cfg = config.chomiamos;
  enableCinnamon = cfg.desktop.env == "cinnamon" || cfg.desktop.env == "both";
  username = cfg.user.username;
in
{
  # =========================================================================
  # 🌿 ENVIRONNEMENT DE BUREAU : CINNAMON DESKTOP
  # =========================================================================

  config = lib.mkIf enableCinnamon {
    # Activation du serveur d'affichage X11 et du bureau Cinnamon
    services.xserver.enable = true;
    services.xserver.desktopManager.cinnamon.enable = true;

    # Gestionnaire de session LightDM avec Slick Greeter (thème officiel Cinnamon)
    services.xserver.displayManager.lightdm.enable = true;
    services.xserver.displayManager.lightdm.greeters.slick.enable = true;
    services.xserver.displayManager.lightdm.greeters.slick.extraConfig = ''
      background=/etc/backgrounds/chomiamos/wallpaper.jpeg
    '';

    # Exclusion de Xterm au niveau serveur d'affichage
    services.xserver.excludePackages = [ pkgs.xterm ];

    # Paquets complémentaires et personnalisation graphique
    users.users."${username}".packages = with pkgs; [
      networkmanagerapplet
      papirus-icon-theme
      adw-gtk3
      dconf-editor
    ];

    # Déploiement du fond d'écran officiel par défaut
    environment.etc."backgrounds/chomiamos/wallpaper.jpeg".source = ../../assets/wallpaper.jpeg;

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

      # 2. Modèles de documents pré-déposés
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
