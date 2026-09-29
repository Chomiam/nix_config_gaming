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

  budgieMenuCatppuccinCss = pkgs.writeText "budgie-menu-catppuccin.css" ''
    /* =========================================================================
     * 🎨 Thème Catppuccin Mocha Lavender pour le Menu Budgie (Budgie Desktop)
     * Élimine la transparence indésirable des catégories et du pied de page
     * ========================================================================= */

    /* Fenêtre globale transparente pour permettre le détourage de la flèche */
    window.budgie-menu-window {
      background-color: transparent;
      box-shadow: none;
      border: none;
    }

    /* Corps principal du menu Budgie */
    window.budgie-menu-window .budgie-menu,
    .budgie-menu {
      background-color: #1e1e2e;
      border-radius: 12px;
      border: 1px solid rgba(205, 214, 244, 0.12);
      box-shadow: 0 8px 32px rgba(0, 0, 0, 0.55), 0 2px 8px rgba(0, 0, 0, 0.3);
      padding: 0;
      margin: 0;
    }

    /* Flèche de liaison entre le menu et le panneau */
    .budgie-menu-arrow {
      color: #1e1e2e;
    }

    /* En-tête du menu (Recherche) */
    .budgie-menu .budgie-menu-header,
    window.budgie-menu-window .budgie-menu-header {
      padding: 10px 10px 6px 10px;
    }

    .budgie-menu entry.search,
    window.budgie-menu-window entry.search {
      background-color: #313244;
      color: #cdd6f4;
      border: 1px solid rgba(205, 214, 244, 0.15);
      border-radius: 8px;
      padding: 6px 10px;
      font-size: 13px;
      box-shadow: none;
      transition: all 150ms ease-in-out;
    }

    .budgie-menu entry.search:focus,
    window.budgie-menu-window entry.search:focus {
      border-color: #b4befe;
      box-shadow: 0 0 0 1px #b4befe;
    }

    /* Colonne de gauche : Catégories */
    .budgie-menu scrolledwindow.sidebar.categories,
    .budgie-menu .sidebar.categories,
    .budgie-menu .categories,
    window.budgie-menu-window .categories {
      background-color: #181825;
      border-top-left-radius: 12px;
      padding: 6px 4px 6px 6px;
    }

    .budgie-menu .category-button,
    window.budgie-menu-window .category-button {
      border-radius: 6px;
      padding: 6px 12px;
      margin: 2px 2px;
      color: #a6adc8;
      font-weight: 500;
      background-color: transparent;
      transition: all 150ms ease-in-out;
    }

    .budgie-menu .category-button:hover,
    window.budgie-menu-window .category-button:hover {
      background-color: rgba(205, 214, 244, 0.08);
      color: #cdd6f4;
    }

    .budgie-menu .category-button:checked,
    .budgie-menu .category-button:active,
    window.budgie-menu-window .category-button:checked,
    window.budgie-menu-window .category-button:active {
      background-color: rgba(180, 190, 254, 0.18);
      color: #b4befe;
      font-weight: 600;
    }

    /* Colonne de droite : Liste des applications */
    .budgie-menu list,
    .budgie-menu listbox,
    window.budgie-menu-window listbox {
      background-color: #1e1e2e;
    }

    .budgie-menu list row,
    .budgie-menu listbox row,
    window.budgie-menu-window listbox row {
      padding: 4px 8px;
      border-radius: 6px;
      margin: 1px 4px;
      color: #cdd6f4;
      transition: background-color 120ms ease-in-out;
    }

    .budgie-menu list row:hover,
    .budgie-menu listbox row:hover,
    window.budgie-menu-window listbox row:hover {
      background-color: rgba(205, 214, 244, 0.08);
    }

    .budgie-menu list row:selected,
    .budgie-menu listbox row:selected,
    window.budgie-menu-window listbox row:selected {
      background-color: #b4befe;
      color: #11111b;
    }

    /* Pied de page du menu (Utilisateur & boutons d'alimentation) */
    .budgie-menu .budgie-menu-footer,
    window.budgie-menu-window .budgie-menu-footer {
      background-color: #181825;
      border-top: 1px solid rgba(205, 214, 244, 0.1);
      border-bottom-left-radius: 12px;
      border-bottom-right-radius: 12px;
      padding: 6px 10px;
    }

    .budgie-menu .budgie-menu-footer button,
    window.budgie-menu-window .budgie-menu-footer button {
      padding: 4px 8px;
      border-radius: 6px;
      color: #cdd6f4;
      transition: all 120ms ease-in-out;
    }

    .budgie-menu .budgie-menu-footer button:hover,
    window.budgie-menu-window .budgie-menu-footer button:hover {
      background-color: rgba(205, 214, 244, 0.1);
      color: #ffffff;
    }

    .budgie-menu .budgie-menu-footer button.user-icon-button,
    window.budgie-menu-window .budgie-menu-footer button.user-icon-button {
      padding-right: 9px;
      font-weight: 500;
    }

    .budgie-menu .budgie-menu-footer button.image-button,
    window.budgie-menu-window .budgie-menu-footer button.image-button {
      border-radius: 9999px;
      padding: 6px;
      min-height: 24px;
      min-width: 24px;
      margin-left: 6px;
    }

    /* Menus de superposition (ex: menu utilisateur, menu arrêt) */
    .budgie-menu list.left-overlay-menu,
    .budgie-menu .left-overlay-menu,
    window.budgie-menu-window .left-overlay-menu {
      border-radius: 10px;
      background-color: #181825;
      padding: 6px;
      margin: 6px;
      border: 1px solid rgba(205, 214, 244, 0.12);
      box-shadow: 0 4px 16px rgba(0, 0, 0, 0.4);
    }

    .budgie-menu list.left-overlay-menu > row.activatable,
    window.budgie-menu-window list.left-overlay-menu > row.activatable {
      border-radius: 6px;
      padding: 4px 8px;
    }

    .budgie-menu list.left-overlay-menu > row.activatable:hover,
    window.budgie-menu-window list.left-overlay-menu > row.activatable:hover {
      background-color: rgba(205, 214, 244, 0.08);
    }
  '';

  gtk3Css = pkgs.concatText "gtk3-catppuccin.css" [
    "${catppuccinTheme}/share/themes/catppuccin-mocha-lavender-standard/gtk-3.0/gtk.css"
    nemoDesktopTransparencyCss
    budgieMenuCatppuccinCss
  ];

  gtk3DarkCss = pkgs.concatText "gtk3-dark-catppuccin.css" [
    "${catppuccinTheme}/share/themes/catppuccin-mocha-lavender-standard/gtk-3.0/gtk-dark.css"
    nemoDesktopTransparencyCss
    budgieMenuCatppuccinCss
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
      theme = "catppuccin-mocha-lavender-standard";
    };
    "org/gnome/shell/extensions/user-theme" = {
      name = "catppuccin-mocha-lavender-standard";
    };
    "com/solus-project/budgie-panel" = {
      dark-theme = true;
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
