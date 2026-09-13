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
      background=/etc/backgrounds/chomiamos/wallpaper_0007.png
    '';

    # Exclusion de Xterm et de GNOME Terminal au niveau de l'environnement Cinnamon
    services.xserver.excludePackages = [ pkgs.xterm ];
    environment.cinnamon.excludePackages = [ pkgs.gnome-terminal ];
    programs.gnome-terminal.enable = lib.mkForce false;

    # Paquets complémentaires et personnalisation graphique
    users.users."${username}".packages = with pkgs; [
      networkmanagerapplet
      papirus-icon-theme
      adw-gtk3
      dconf-editor
    ];

    # Création proactive des répertoires d'applications Flatpak et Cinnamon
    # Permet à cinnamon-menus d'attacher ses écouteurs inotify dès le premier démarrage
    systemd.tmpfiles.rules = [
      "d /var/lib/flatpak/exports/share/applications 0755 root root -"
    ];

    systemd.user.tmpfiles.rules = [
      "d %h/.local/share/flatpak/exports/share/applications 0755 - - -"
      "d %h/.local/share/applications 0755 - - -"
      "d %h/.config/cinnamon/backgrounds 0755 - - -"
      "d %h/.config/chomiamos 0755 - - -"
    ];

    # Script et service de synchronisation continue Cinnamon -> GNOME pour les fonds d'écran
    # Empêche BackgroundManager.js de Cinnamon d'écraser le wallpaper choisi par l'utilisateur
    environment.systemPackages = [
      (pkgs.writeShellScriptBin "chomiamos-cinnamon-wallpaper-sync" ''
        if pidof -x -o $$ chomiamos-cinnamon-wallpaper-sync >/dev/null 2>&1; then
          exit 0
        fi

        # 1. Alignement initial au démarrage de la session
        CIN_BG=$(${pkgs.glib}/bin/gsettings get org.cinnamon.desktop.background picture-uri 2>/dev/null || true)
        if [ -n "$CIN_BG" ] && [ "$CIN_BG" != "none" ] && [ "$CIN_BG" != "@as []" ]; then
          ${pkgs.glib}/bin/gsettings set org.gnome.desktop.background picture-uri "$CIN_BG" 2>/dev/null || true
          ${pkgs.glib}/bin/gsettings set org.gnome.desktop.background picture-uri-dark "$CIN_BG" 2>/dev/null || true
        fi

        # 2. Surveillance dynamique des changements de fond d'écran dans Cinnamon
        ${pkgs.glib}/bin/gsettings monitor org.cinnamon.desktop.background picture-uri 2>/dev/null | while read -r _; do
          NEW_BG=$(${pkgs.glib}/bin/gsettings get org.cinnamon.desktop.background picture-uri 2>/dev/null || true)
          if [ -n "$NEW_BG" ] && [ "$NEW_BG" != "none" ]; then
            ${pkgs.glib}/bin/gsettings set org.gnome.desktop.background picture-uri "$NEW_BG" 2>/dev/null || true
            ${pkgs.glib}/bin/gsettings set org.gnome.desktop.background picture-uri-dark "$NEW_BG" 2>/dev/null || true
          fi
        done
      '')
    ];

    # Service systemd utilisateur pour exécuter la synchronisation continue
    systemd.user.services.chomiamos-cinnamon-wallpaper-sync = {
      description = "ChomiamOS Cinnamon to GNOME Wallpaper Sync";
      wantedBy = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.writeShellScript "cinnamon-wallpaper-sync-runner" ''
          exec /run/current-system/sw/bin/chomiamos-cinnamon-wallpaper-sync
        ''}";
        Restart = "on-failure";
        RestartSec = "5s";
      };
    };

    # Autostart XDG complémentaire pour garantir l'exécution de la synchronisation
    environment.etc."xdg/autostart/chomiamos-cinnamon-wallpaper-sync.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=ChomiamOS Cinnamon Wallpaper Sync
      Exec=/run/current-system/sw/bin/chomiamos-cinnamon-wallpaper-sync
      OnlyShowIn=X-Cinnamon;Cinnamon;
      NoDisplay=true
      X-GNOME-Autostart-Phase=Desktop
    '';

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
