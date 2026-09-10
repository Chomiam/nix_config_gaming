{ pkgs, lib, vars, ... }:

let
  isKde = vars.desktopEnv == "kde";
  catppuccinTheme = pkgs.catppuccin-gtk.override {
    variant = "mocha";
    accents = [ "lavender" ];
  };
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
    gtk4.extraConfig.gtk-application-prefer-dark-theme = 1;

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

  # Déploiement des fichiers CSS et Assets pour GTK4 / Libadwaita et GTK3 (GNOME uniquement)
  # Évite les conflits et écrasements perpétuels avec les modifications de thème sous KDE
  xdg.configFile = lib.mkIf (!isKde) {
    "gtk-4.0/gtk.css" = {
      source = "${catppuccinTheme}/share/themes/catppuccin-mocha-lavender-standard/gtk-4.0/gtk.css";
      force = true;
    };
    "gtk-4.0/gtk-dark.css" = {
      source = "${catppuccinTheme}/share/themes/catppuccin-mocha-lavender-standard/gtk-4.0/gtk-dark.css";
      force = true;
    };
    "gtk-4.0/assets" = {
      source = "${catppuccinTheme}/share/themes/catppuccin-mocha-lavender-standard/gtk-4.0/assets";
      force = true;
    };

    "gtk-3.0/gtk.css" = {
      source = "${catppuccinTheme}/share/themes/catppuccin-mocha-lavender-standard/gtk-3.0/gtk.css";
      force = true;
    };
    "gtk-3.0/gtk-dark.css" = {
      source = "${catppuccinTheme}/share/themes/catppuccin-mocha-lavender-standard/gtk-3.0/gtk-dark.css";
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
      accent-color = "purple";
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
