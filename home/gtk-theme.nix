{ pkgs, lib, vars, ... }:

let
  isKde = vars.desktopEnv == "kde";
  catppuccinTheme = pkgs.catppuccin-gtk.override {
    variant = "mocha";
    accents = [ "lavender" ];
  };

  nemoDesktopTransparencyCss = pkgs.writeText "nemo-desktop-transparency.css" ''
    /* =========================================================================
     * Correctif de transparence pour Nemo Desktop (Cinnamon)
     * Empêche l'aplat de couleur opaque Catppuccin d'obstruer le fond d'écran.
     * ========================================================================= */
    .nemo-desktop-window,
    .nemo-desktop-window *,
    .nemo-desktop-window .view,
    .nemo-desktop.view,
    .nemo-desktop-window canvas,
    .nemo-desktop-window scrolledwindow,
    .nemo-desktop-window viewport {
      background-color: transparent;
    }
  '';

  gtk3Css = pkgs.concatText "gtk3-catppuccin.css" [
    "${catppuccinTheme}/share/themes/catppuccin-mocha-lavender-standard/gtk-3.0/gtk.css"
    nemoDesktopTransparencyCss
  ];

  gtk3DarkCss = pkgs.concatText "gtk3-dark-catppuccin.css" [
    "${catppuccinTheme}/share/themes/catppuccin-mocha-lavender-standard/gtk-3.0/gtk-dark.css"
    nemoDesktopTransparencyCss
  ];

  gtk4LibadwaitaCss = pkgs.writeText "gtk4-catppuccin-mocha.css" ''
    /* =========================================================================
     * 🎨 Thème Catppuccin Mocha pour GTK4 / Libadwaita
     * Compatible avec les couleurs d'accentuation natives de GNOME 47+
     * ========================================================================= */

    @define-color window_bg_color #1e1e2e;
    @define-color window_fg_color #cdd6f4;
    @define-color view_bg_color #181825;
    @define-color view_fg_color #cdd6f4;
    @define-color headerbar_bg_color #181825;
    @define-color headerbar_fg_color #cdd6f4;
    @define-color headerbar_border_color rgba(205, 214, 244, 0.12);
    @define-color headerbar_backdrop_color #1e1e2e;
    @define-color card_bg_color rgba(255, 255, 255, 0.05);
    @define-color card_fg_color #cdd6f4;
    @define-color dialog_bg_color #1e1e2e;
    @define-color dialog_fg_color #cdd6f4;
    @define-color popover_bg_color #181825;
    @define-color popover_fg_color #cdd6f4;
    @define-color sidebar_bg_color #181825;
    @define-color sidebar_fg_color #cdd6f4;
    @define-color secondary_sidebar_bg_color #181825;
    @define-color secondary_sidebar_fg_color #cdd6f4;
    @define-color thumbnail_bg_color #181825;
    @define-color thumbnail_fg_color #cdd6f4;

    /* Couleurs sémantiques Catppuccin */
    @define-color destructive_bg_color #f38ba8;
    @define-color destructive_fg_color #11111b;
    @define-color success_bg_color #a6e3a1;
    @define-color success_fg_color #11111b;
    @define-color warning_bg_color #f9e2af;
    @define-color warning_fg_color #11111b;
    @define-color error_bg_color #f38ba8;
    @define-color error_fg_color #11111b;

    /* =========================================================================
     * 🟢 Boutons de contrôle de fenêtre Catppuccin (Fermer, Minimiser, Maximiser)
     * ========================================================================= */
    windowcontrols {
      border-spacing: 6px;
    }

    windowcontrols:not(.empty).start:dir(ltr), windowcontrols:not(.empty).end:dir(rtl) {
      margin-right: 6px;
      margin-left: 6px;
    }

    windowcontrols:not(.empty).start:dir(rtl), windowcontrols:not(.empty).end:dir(ltr) {
      margin-left: 6px;
      margin-right: 6px;
    }

    windowcontrols > button {
      min-height: 14px;
      min-width: 14px;
      padding: 0;
      margin: 0 3px;
      border-radius: 9999px;
      border: none;
      box-shadow: none;
    }

    windowcontrols > button > image {
      border-radius: 9999px;
      padding: 0;
      min-height: 14px;
      min-width: 14px;
    }

    windowcontrols > button.minimize,
    windowcontrols > button.maximize,
    windowcontrols > button.close {
      color: transparent;
      background: none;
    }

    windowcontrols > button.minimize:hover,
    windowcontrols > button.minimize:active,
    windowcontrols > button.maximize:hover,
    windowcontrols > button.maximize:active,
    windowcontrols > button.close:hover,
    windowcontrols > button.close:active {
      color: rgba(17, 17, 27, 0.87);
      box-shadow: none;
    }

    windowcontrols > button.minimize > image {
      background-color: #f9e2af;
    }

    windowcontrols > button.minimize:active > image {
      background-color: #f7e6c1;
    }

    windowcontrols > button.maximize > image {
      background-color: #a6e3a1;
    }

    windowcontrols > button.maximize:active > image {
      background-color: #b8e7b6;
    }

    windowcontrols > button.close > image {
      background-color: #f38ba8;
    }

    windowcontrols > button.close:active > image {
      background-color: #f2a5bb;
    }

    windowcontrols > button.minimize:backdrop > image,
    windowcontrols > button.maximize:backdrop > image,
    windowcontrols > button.close:backdrop > image {
      background-color: rgba(239, 241, 245, 0.3);
    }
  '';
in
{
  # =========================================================================
  # 🎨 THÈME GTK, ICÔNES & CURSEUR (CATPPUCCIN MOCHA LAVENDER)
  # =========================================================================

  # Sous KDE Plasma, on laisse le gestionnaire natif (kde-gtk-config) synchroniser
  # les thèmes GTK avec le thème Plasma choisi par l'utilisateur dans les Paramètres.
  # Sous GNOME, on applique déclarativement le thème Catppuccin complet.
  gtk = lib.mkIf (!isKde) {
    enable = true;

    gtk2.extraConfig = "gtk-application-prefer-dark-theme = 1";
    gtk3.extraConfig.gtk-application-prefer-dark-theme = 1;

    theme = {
      name = "catppuccin-mocha-lavender-standard";
      package = catppuccinTheme;
    };

    iconTheme = {
      name = "Papirus-Dark";
      package = lib.mkForce (
        pkgs.catppuccin-papirus-folders.override {
          flavor = "mocha";
          accent = "lavender";
        }
      );
    };

    cursorTheme = {
      name = "catppuccin-mocha-lavender-cursors";
      package = pkgs.catppuccin-cursors.mochaLavender;
      size = 24;
    };
  };

  # Déploiement des fichiers CSS pour GTK4 / Libadwaita et GTK3 (GNOME uniquement)
  # Évite les conflits et écrasements perpétuels avec les modifications de thème sous KDE
  xdg.configFile = lib.mkIf (!isKde) {
    "gtk-4.0/gtk.css" = {
      source = gtk4LibadwaitaCss;
      force = true;
    };
    "gtk-4.0/gtk-dark.css" = {
      source = gtk4LibadwaitaCss;
      force = true;
    };

    "gtk-3.0/gtk.css" = {
      source = gtk3Css;
      force = true;
    };
    "gtk-3.0/gtk-dark.css" = {
      source = gtk3DarkCss;
      force = true;
    };
    "gtk-3.0/assets" = {
      source = "${catppuccinTheme}/share/themes/catppuccin-mocha-lavender-standard/gtk-3.0/assets";
      force = true;
    };
  };

  # Activation déclarative du thème Catppuccin pour GNOME
  dconf.settings = lib.mkIf (!isKde) {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      gtk-theme = "catppuccin-mocha-lavender-standard";
      cursor-theme = "catppuccin-mocha-lavender-cursors";
      icon-theme = "Papirus-Dark";
    };
    "org/gnome/desktop/wm/preferences" = {
      button-layout = "icon:minimize,maximize,close";
    };
    "org/gnome/shell/extensions/user-theme" = {
      name = "catppuccin-mocha-lavender-standard";
    };
  };

  home.pointerCursor = {
    enable = true;
    name = "catppuccin-mocha-lavender-cursors";
    package = pkgs.catppuccin-cursors.mochaLavender;
    size = 24;
    gtk.enable = !isKde;
    x11.enable = true;
  };

  home.packages = with pkgs; [
    catppuccinTheme
    catppuccin-cursors.mochaLavender
  ];
}
