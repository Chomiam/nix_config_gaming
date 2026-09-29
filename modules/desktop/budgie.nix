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

  # Thème de bordures et décorations de fenêtres labwc / openbox (Catppuccin Mocha Lavender)
  catppuccinLabwcTheme = pkgs.runCommand "catppuccin-mocha-lavender-labwc" {} ''
    mkdir -p $out/share/themes/catppuccin-mocha-lavender-standard/labwc
    mkdir -p $out/share/themes/catppuccin-mocha-lavender-standard/openbox-3
    mkdir -p $out/share/budgie-desktop/labwc
    cp -r ${./budgie-labwc-theme}/* $out/share/themes/catppuccin-mocha-lavender-standard/labwc/
    cp -r ${./budgie-labwc-theme}/* $out/share/themes/catppuccin-mocha-lavender-standard/openbox-3/
    cp ${./budgie-labwc-theme}/themerc $out/share/budgie-desktop/labwc/themerc-mocha
  '';

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
  # 🐦 ENVIRONNEMENT DE BUREAU : BUDGIE DESKTOP (CANAL STABLE NIXPKGS)
  # Intégration complète du thème Catppuccin Mocha Lavender
  # =========================================================================

  config = lib.mkIf enableBudgie {
    # 0. Correctif officiel Budgie Desktop : Focus automatique de la recherche du menu lors de l'appui sur Super (PR #964 / Issue #842)
    nixpkgs.overlays = [
      (final: prev: {
        budgie-desktop = prev.budgie-desktop.overrideAttrs (oldAttrs: {
          patches = (oldAttrs.patches or [ ]) ++ [
            ./budgie-menu-focus.patch
          ];
        });
      })
    ];

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

      [org.gnome.desktop.peripherals.keyboard]
      numlock-state=true
      remember-numlock-state=true

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
          activate-numlock=true
        '';
      };
    };

    # 4. Exclusion de Xterm au niveau serveur d'affichage
    services.xserver.excludePackages = [ pkgs.xterm ];

    # 5. Association par défaut de Loupe pour l'ouverture des images
    xdg.mime.defaultApplications = imageMimeAssociations;

    # 6. Paquets Catppuccin et outils indispensables pour Budgie (avec Loupe)
    environment.systemPackages = [
      catppuccinLabwcTheme
      pkgs.loupe
    ];

    users.users."${username}".packages = with pkgs; [
      catppuccinTheme
      catppuccinPapirus
      catppuccin-cursors.mochaLavender
      catppuccinLabwcTheme
      networkmanagerapplet
      adw-gtk3
      dconf-editor
      loupe
    ];

    # 7. Configuration déclarative Home-Manager pour les fenêtres Budgie / labwc et MIME
    home-manager.users."${username}" = {
      xdg.configFile."budgie-desktop/labwc/themerc-override".source = "${./budgie-labwc-theme}/themerc";
      xdg.dataFile."themes/catppuccin-mocha-lavender-standard/labwc" = {
        source = ./budgie-labwc-theme;
        recursive = true;
      };
      xdg.dataFile."themes/catppuccin-mocha-lavender-standard/openbox-3" = {
        source = ./budgie-labwc-theme;
        recursive = true;
      };
      xdg.mimeApps = {
        enable = true;
        defaultApplications = imageMimeAssociationsList;
      };
    };

    # 8. Création proactive des répertoires pour Flatpak et Budgie
    systemd.tmpfiles.rules = [
      "d /var/lib/flatpak/exports/share/applications 0755 root root -"
    ];

    systemd.user.tmpfiles.rules = [
      "d %h/.local/share/flatpak/exports/share/applications 0755 - - -"
      "d %h/.local/share/applications 0755 - - -"
      "d %h/.config/chomiamos 0755 - - -"
      "d %h/.config/budgie-desktop/labwc 0755 - - -"
    ];
  };
}
