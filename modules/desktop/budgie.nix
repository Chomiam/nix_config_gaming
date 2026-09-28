{ config, lib, pkgs, browserInfo, ... }:

let
  cfg = config.chomiamos;
  enableBudgie = cfg.desktop.env == "budgie";
  username = cfg.user.username;

  catppuccinTheme = pkgs.catppuccin-gtk.override {
    variant = "mocha";
    accents = [ "lavender" ];
  };

  catppuccinPapirus = pkgs.catppuccin-papirus-folders.override {
    flavor = "mocha";
    accent = "lavender";
  };
in
{
  # =========================================================================
  # 🐦 ENVIRONNEMENT DE BUREAU : BUDGIE DESKTOP (CANAL STABLE NIXPKGS)
  # Intégration complète du thème Catppuccin Mocha Lavender
  # =========================================================================

  config = lib.mkIf enableBudgie {
    # 1. Activation du serveur d'affichage X11 et du bureau Budgie (canal stable)
    services.xserver.enable = true;
    services.desktopManager.budgie.enable = true;

    # 2. Thème Catppuccin Mocha complet injecté au niveau système via GSettings overrides
    services.desktopManager.budgie.extraGSettingsOverrides = ''
      [org.gnome.desktop.interface]
      color-scheme='prefer-dark'
      gtk-theme='catppuccin-mocha-lavender-standard'
      icon-theme='Papirus-Dark'
      cursor-theme='catppuccin-mocha-lavender-cursors'
      cursor-size=24

      [org.gnome.desktop.wm.preferences]
      theme='catppuccin-mocha-lavender-standard'
      button-layout='appmenu:minimize,maximize,close'

      [org.gnome.desktop.background]
      picture-uri='file:///etc/backgrounds/chomiamos/wallpaper_0007.png'
      picture-uri-dark='file:///etc/backgrounds/chomiamos/wallpaper_0007.png'
      primary-color='#1e1e2e'

      [org.gnome.desktop.screensaver]
      picture-uri='file:///etc/backgrounds/chomiamos/wallpaper_0007.png'
      primary-color='#1e1e2e'

      [com.solus-project.budgie-panel]
      dark-theme=true

      [com.solus-project.budgie-wm]
      button-layout='appmenu:minimize,maximize,close'
    '';

    # 3. Gestionnaire de session LightDM avec Slick Greeter thématisé en Catppuccin Mocha
    services.xserver.displayManager.lightdm = {
      enable = true;
      greeters.slick = {
        enable = true;
        theme = {
          name = "catppuccin-mocha-lavender-standard";
          package = catppuccinTheme;
        };
        iconTheme = {
          name = "Papirus-Dark";
          package = catppuccinPapirus;
        };
        cursorTheme = {
          name = "catppuccin-mocha-lavender-cursors";
          package = pkgs.catppuccin-cursors.mochaLavender;
        };
        extraConfig = ''
          background=/etc/backgrounds/chomiamos/wallpaper_0007.png
        '';
      };
    };

    # 4. Exclusion de Xterm au niveau serveur d'affichage
    services.xserver.excludePackages = [ pkgs.xterm ];

    # 5. Paquets Catppuccin et outils indispensables pour Budgie
    users.users."${username}".packages = with pkgs; [
      catppuccinTheme
      catppuccinPapirus
      catppuccin-cursors.mochaLavender
      networkmanagerapplet
      adw-gtk3
      dconf-editor
    ];

    # 6. Création proactive des répertoires pour Flatpak et Budgie
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
