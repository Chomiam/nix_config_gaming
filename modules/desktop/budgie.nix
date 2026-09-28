{ config, lib, pkgs, browserInfo, ... }:

let
  cfg = config.chomiamos;
  enableBudgie = cfg.desktop.env == "budgie";
  username = cfg.user.username;
in
{
  # =========================================================================
  # 🐦 ENVIRONNEMENT DE BUREAU : BUDGIE DESKTOP (CANAL STABLE NIXPKGS)
  # =========================================================================

  config = lib.mkIf enableBudgie {
    # 1. Activation du serveur d'affichage X11 et du bureau Budgie (canal stable)
    services.xserver.enable = true;
    services.desktopManager.budgie.enable = true;

    # 2. Gestionnaire de session LightDM avec Slick Greeter (inclus et configuré par défaut dans nixpkgs pour Budgie)
    services.xserver.displayManager.lightdm = {
      enable = true;
      greeters.slick = {
        enable = true;
        extraConfig = ''
          background=/etc/backgrounds/chomiamos/wallpaper_0007.png
        '';
      };
    };

    # 3. Exclusion de Xterm au niveau serveur d'affichage
    services.xserver.excludePackages = [ pkgs.xterm ];

    # 4. Paquets complémentaires pour l'utilisateur principal sous Budgie
    users.users."${username}".packages = with pkgs; [
      networkmanagerapplet
      adw-gtk3
      dconf-editor
      qogir-theme
      qogir-icon-theme
      catppuccin-gtk
      catppuccin-papirus-folders
      catppuccin-cursors.mochaLavender
    ];

    # 5. Création proactive des répertoires d'applications Flatpak et Budgie
    systemd.tmpfiles.rules = [
      "d /var/lib/flatpak/exports/share/applications 0755 root root -"
    ];

    systemd.user.tmpfiles.rules = [
      "d %h/.local/share/flatpak/exports/share/applications 0755 - - -"
      "d %h/.local/share/applications 0755 - - -"
      "d %h/.config/chomiamos 0755 - - -"
    ];
  };
}
