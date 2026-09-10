{ config, lib, pkgs, ... }:

let
  cfg = config.chomiamos;
  enableKde = cfg.desktop.env == "kde" || cfg.desktop.env == "both";
  username = cfg.user.username;

  catppuccinKdeMocha = pkgs.catppuccin-kde.override {
    flavour = [ "mocha" ];
    accents = [ "lavender" ];
  };

  catppuccinPapirus = pkgs.catppuccin-papirus-folders.override {
    flavor = "mocha";
    accent = "lavender";
  };
in
{
  # =========================================================================
  # ❄️ ENVIRONNEMENT DE BUREAU : KDE PLASMA 6
  # =========================================================================

  config = lib.mkIf enableKde {
    # 1. Activation de KDE Plasma 6
    services.desktopManager.plasma6.enable = true;

    # 2. Gestionnaire d'affichage SDDM (Wayland par défaut pour Plasma 6)
    services.displayManager.sddm = {
      enable = true;
      wayland.enable = true;
    };
    services.displayManager.defaultSession = "plasma";

    # 3. Exclusion des paquets KDE superflus
    environment.plasma6.excludePackages = with pkgs.kdePackages; [
      elisa
      khelpcenter
    ];

    # 4. Paquets minimaux & thèmes Catppuccin
    users.users."${username}".packages = with pkgs; [
      catppuccinKdeMocha
      catppuccinPapirus
      catppuccin-cursors.mochaLavender
      papirus-icon-theme
      kdePackages.ark
      kdePackages.spectacle
      kdePackages.kcalc
      kdePackages.dolphin
      kdePackages.kate
      kdePackages.kconfig
      kdePackages.plasma-workspace
    ];

    # Déploiement du fond d'écran officiel par défaut
    environment.etc."backgrounds/chomiamos/wallpaper.jpeg".source = ../../assets/wallpaper.jpeg;

    # 5. Configuration Home Manager
    home-manager.users."${username}" = { config, ... }: {
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
