{ config, lib, pkgs, browserInfo, ... }:

let
  cfg = config.chomiamos;
  enableGnome = cfg.desktop.env == "gnome" || cfg.desktop.env == "both";
  enableCosmic = cfg.desktop.env == "cosmic" || cfg.desktop.env == "both";
  enableCinnamon = cfg.desktop.env == "cinnamon" || cfg.desktop.env == "both";

  catppuccinTheme = pkgs.catppuccin-gtk.override {
    variant = "mocha";
    accents = [ "lavender" ];
  };

  # =========================================================================
  # 1. CONFIGURATION INITIALE POUR GNOME SHELL (DCONF)
  # =========================================================================

  gnomeFavorites = [
    "chomiamos-dashboard.desktop"
    "kitty.desktop"
    "org.gnome.Settings.desktop"
    "org.gnome.Nautilus.desktop"
    "io.github.kolunmi.Bazaar.desktop"
    browserInfo.desktopFile
  ] ++ (
    if cfg.discordClient == "discord" then [ "discord.desktop" ]
    else if cfg.discordClient == "equibop" then [ "io.github.equicord.equibop.desktop" ]
    else if cfg.discordClient == "vesktop" then [ "dev.vencord.Vesktop.desktop" ]
    else []
  ) ++ pkgs.lib.optionals cfg.gaming.launchers.steam [
    "steam.desktop"
  ] ++ pkgs.lib.optionals cfg.gaming.launchers.lutris [
    "net.lutris.Lutris.desktop"
  ] ++ pkgs.lib.optionals cfg.gaming.launchers.heroic [
    "com.heroicgameslauncher.hgl.desktop"
  ] ++ pkgs.lib.optionals cfg.gaming.launchers.faugus [
    "faugus-launcher.desktop"
  ] ++ pkgs.lib.optionals cfg.gaming.geforceNow [
    "com.nvidia.geforcenow.desktop"
  ] ++ [
    "onlyoffice-desktopeditors.desktop"
    "thunderbird.desktop"
  ] ++ pkgs.lib.optionals cfg.services.obs.enable [
    "com.obsproject.Studio.desktop"
  ];

  gnomeFavoritesStr = "[" + (lib.concatMapStringsSep ", " (x: "'${x}'") gnomeFavorites) + "]";

  gnomeExtensions = [
    "user-theme@gnome-shell-extensions.gcampax.github.com"
    "appindicatorsupport@rgcjonas.gmail.com"
    "Vitals@CoreCoding.com"
    "clipboard-indicator@tudmotu.com"
    "arcmenu@arcmenu.com"
    "blur-my-shell@aunetx"
    "dash-to-dock@micxgx.gmail.com"
    "no-overview@fthx"
  ];

  gnomeExtensionsStr = "[" + (lib.concatMapStringsSep ", " (x: "'${x}'") gnomeExtensions) + "]";

  gnomeDefaultsIni = pkgs.writeText "chomiamos-gnome-defaults.ini" ''
    [org/gnome/shell]
    enabled-extensions=${gnomeExtensionsStr}
    favorite-apps=${gnomeFavoritesStr}

    [org/gnome/shell/extensions/user-theme]
    name='catppuccin-mocha-lavender-standard'

    [org/gnome/desktop/wm/preferences]
    button-layout='icon:minimize,maximize,close'

    [org/gnome/mutter]
    experimental-features=['scale-monitor-framebuffer', 'xwayland-native-scaling', 'hdr']

    [org/gnome/desktop/interface]
    accent-color='purple'
    color-scheme='prefer-dark'
    gtk-theme='catppuccin-mocha-lavender-standard'
    cursor-theme='catppuccin-mocha-lavender-cursors'
    icon-theme='Papirus-Dark'

    [org/gnome/desktop/background]
    picture-uri='file:///etc/backgrounds/chomiamos/wallpaper.jpeg'
    picture-uri-dark='file:///etc/backgrounds/chomiamos/wallpaper.jpeg'
    picture-options='zoom'

    [org/gnome/desktop/screensaver]
    picture-uri='file:///etc/backgrounds/chomiamos/wallpaper.jpeg'
    picture-options='zoom'

    [org/gnome/shell/extensions/dash-to-dock]
    dock-position='LEFT'
    dock-fixed=true
    extend-height=true
    dash-max-icon-size=48
    height-fraction=0.9
    background-opacity=0.8
    custom-theme-shrink=true
    hide-tooltip=false
    preferred-monitor=-2
    show-icons-notifications-counter=false
    show-show-apps-button=false

    [org/gnome/shell/extensions/arcmenu]
    menu-button-appearance='None'
    menu-layout='runner'
    prefs-visible-page=0
    search-entry-border-radius=(true, 25)
    update-notifier-project-version=73

    [org/gnome/shell/extensions/blur-my-shell]
    pipelines={'pipeline_default': {'name': <'Default'>, 'effects': <[<{'type': <'native_static_gaussian_blur'>, 'id': <'effect_000000000000'>, 'params': <{'radius': <30>, 'brightness': <0.6>}>}>]>}, 'pipeline_default_rounded': {'name': <'Default rounded'>, 'effects': <[<{'type': <'native_static_gaussian_blur'>, 'id': <'effect_000000000001'>, 'params': <{'radius': <30>, 'brightness': <0.6>}>}>]>}}
    rounded-blur-found=false
    settings-version=2

    [org/gnome/shell/extensions/blur-my-shell/appfolder]
    brightness=0.6
    sigma=30

    [org/gnome/shell/extensions/blur-my-shell/applications]
    blur=true
    blur-on-overview=true
    dynamic-opacity=false
    enable-all=false
    pipeline='pipeline_default'
    sigma=30
    static-blur=false
    whitelist=['org.gnome.Nautilus']

    [org/gnome/shell/extensions/blur-my-shell/coverflow-alt-tab]
    pipeline='pipeline_default'

    [org/gnome/shell/extensions/blur-my-shell/dash-to-dock]
    blur=true
    brightness=0.6
    pipeline='pipeline_default_rounded'
    sigma=30
    static-blur=true
    style-dash-to-dock=0

    [org/gnome/shell/extensions/blur-my-shell/lockscreen]
    pipeline='pipeline_default'

    [org/gnome/shell/extensions/blur-my-shell/overview]
    pipeline='pipeline_default'

    [org/gnome/shell/extensions/blur-my-shell/panel]
    brightness=0.6
    corner-radius=0
    pipeline='pipeline_default'
    sigma=30

    [org/gnome/shell/extensions/blur-my-shell/screenshot]
    pipeline='pipeline_default'

    [org/gnome/shell/extensions/blur-my-shell/window-list]
    brightness=0.6
    sigma=30
  '';

  # =========================================================================
  # 2. CONFIGURATION INITIALE POUR COSMIC DESKTOP (FAVORIS)
  # =========================================================================

  cosmicFavorites = [
    "chomiamos-dashboard"
    "kitty"
    "com.system76.CosmicSettings"
    "com.system76.CosmicFiles"
    "io.github.kolunmi.Bazaar"
    browserInfo.cosmicId
  ] ++ (
    if cfg.discordClient == "discord" then [ "discord" ]
    else if cfg.discordClient == "equibop" then [ "io.github.equicord.equibop" ]
    else if cfg.discordClient == "vesktop" then [ "dev.vencord.Vesktop" ]
    else []
  ) ++ pkgs.lib.optionals cfg.gaming.launchers.steam [
    "steam"
  ] ++ pkgs.lib.optionals cfg.gaming.launchers.lutris [
    "net.lutris.Lutris"
  ] ++ pkgs.lib.optionals cfg.gaming.launchers.heroic [
    "com.heroicgameslauncher.hgl"
  ] ++ pkgs.lib.optionals cfg.gaming.launchers.faugus [
    "faugus-launcher"
  ] ++ pkgs.lib.optionals cfg.gaming.geforceNow [
    "com.nvidia.geforcenow"
  ] ++ [
    "onlyoffice-desktopeditors"
    "thunderbird"
  ] ++ pkgs.lib.optionals cfg.services.obs.enable [
    "com.obsproject.Studio"
  ];

  cosmicFavoritesJson = pkgs.writeText "chomiamos-cosmic-favorites.ron" (
    "[\n" + (lib.concatMapStringsSep ",\n" (x: "    \"${x}\"") cosmicFavorites) + "\n]\n"
  );

  # =========================================================================
  # 3. CONFIGURATION INITIALE POUR CINNAMON (DCONF)
  # =========================================================================

  cinnamonFavorites = [
    "chomiamos-dashboard.desktop"
    "kitty.desktop"
    "cinnamon-settings.desktop"
    "nemo.desktop"
    "io.github.kolunmi.Bazaar.desktop"
    browserInfo.desktopFile
  ] ++ (
    if cfg.discordClient == "discord" then [ "discord.desktop" ]
    else if cfg.discordClient == "equibop" then [ "io.github.equicord.equibop.desktop" ]
    else if cfg.discordClient == "vesktop" then [ "dev.vencord.Vesktop.desktop" ]
    else []
  ) ++ pkgs.lib.optionals cfg.gaming.launchers.steam [
    "steam.desktop"
  ] ++ pkgs.lib.optionals cfg.gaming.launchers.lutris [
    "net.lutris.Lutris.desktop"
  ] ++ pkgs.lib.optionals cfg.gaming.launchers.heroic [
    "com.heroicgameslauncher.hgl.desktop"
  ] ++ pkgs.lib.optionals cfg.gaming.launchers.faugus [
    "faugus-launcher.desktop"
  ] ++ pkgs.lib.optionals cfg.gaming.geforceNow [
    "com.nvidia.geforcenow.desktop"
  ] ++ [
    "onlyoffice-desktopeditors.desktop"
    "thunderbird.desktop"
  ] ++ pkgs.lib.optionals cfg.services.obs.enable [
    "com.obsproject.Studio.desktop"
  ];

  cinnamonFavoritesStr = "[" + (lib.concatMapStringsSep ", " (x: "'${x}'") cinnamonFavorites) + "]";

  cinnamonDefaultsIni = pkgs.writeText "chomiamos-cinnamon-defaults.ini" ''
    [org/cinnamon]
    favorite-apps=${cinnamonFavoritesStr}

    [org/cinnamon/desktop/wm/preferences]
    button-layout='icon:minimize,maximize,close'

    [org/cinnamon/desktop/interface]
    clock-use-24h=true
    gtk-theme='catppuccin-mocha-lavender-standard'
    cursor-theme='catppuccin-mocha-lavender-cursors'
    icon-theme='Papirus-Dark'

    [org/cinnamon/desktop/background]
    picture-uri='file:///etc/backgrounds/chomiamos/wallpaper.jpeg'
    picture-options='zoom'

    [org/cinnamon/desktop/screensaver]
    picture-uri='file:///etc/backgrounds/chomiamos/wallpaper.jpeg'
    picture-options='zoom'

    [org/cinnamon/theme]
    name='Mint-Y-Dark'
  '';

  # =========================================================================
  # 4. SCRIPTS DE PROVISIONNEMENT ET DE RÉINITIALISATION
  # =========================================================================

  setupScript = pkgs.writeShellScriptBin "chomiamos-desktop-setup" ''
    set -euo pipefail

    FORCE=0
    for arg in "$@"; do
      if [ "$arg" = "--force" ] || [ "$arg" = "-f" ]; then
        FORCE=1
      fi
    done

    SENTINEL="$HOME/.config/chomiamos/.desktop-initialized"

    if [ "$FORCE" -eq 1 ] || [ ! -f "$SENTINEL" ]; then
      echo "[ChomiamOS] Initialisation de l'interface utilisateur..."
      ${pkgs.coreutils}/bin/mkdir -p "$HOME/.config/chomiamos"

      # Déploiement sécurisé du thème Catppuccin GTK4 et GTK3 dans le profil utilisateur
      ${pkgs.coreutils}/bin/mkdir -p "$HOME/.config/gtk-4.0" "$HOME/.config/gtk-3.0"
      ${pkgs.coreutils}/bin/ln -sf "${catppuccinTheme}/share/themes/catppuccin-mocha-lavender-standard/gtk-4.0/gtk.css" "$HOME/.config/gtk-4.0/gtk.css"
      ${pkgs.coreutils}/bin/ln -sf "${catppuccinTheme}/share/themes/catppuccin-mocha-lavender-standard/gtk-4.0/gtk-dark.css" "$HOME/.config/gtk-4.0/gtk-dark.css"
      ${pkgs.coreutils}/bin/ln -sfn "${catppuccinTheme}/share/themes/catppuccin-mocha-lavender-standard/gtk-4.0/assets" "$HOME/.config/gtk-4.0/assets"
      ${pkgs.coreutils}/bin/ln -sf "${catppuccinTheme}/share/themes/catppuccin-mocha-lavender-standard/gtk-3.0/gtk.css" "$HOME/.config/gtk-3.0/gtk.css"
      ${pkgs.coreutils}/bin/ln -sf "${catppuccinTheme}/share/themes/catppuccin-mocha-lavender-standard/gtk-3.0/gtk-dark.css" "$HOME/.config/gtk-3.0/gtk-dark.css"
      ${pkgs.coreutils}/bin/ln -sfn "${catppuccinTheme}/share/themes/catppuccin-mocha-lavender-standard/gtk-3.0/assets" "$HOME/.config/gtk-3.0/assets"

      ${lib.optionalString enableGnome ''
      # Initialisation GNOME (dconf)
      if [ -x "${pkgs.dconf}/bin/dconf" ]; then
        echo "[ChomiamOS] Déploiement des réglages GNOME par défaut (fond d'écran, extensions, dock)..."
        ${pkgs.dconf}/bin/dconf load / < "${gnomeDefaultsIni}" || true
      fi
      ''}

      ${lib.optionalString enableCosmic ''
      # Initialisation COSMIC (favoris du dock)
      COSMIC_FAV_DIR="$HOME/.config/cosmic/com.system76.CosmicAppList/v1"
      ${pkgs.coreutils}/bin/mkdir -p "$COSMIC_FAV_DIR"
      if [ "$FORCE" -eq 1 ] || [ ! -f "$COSMIC_FAV_DIR/favorites" ]; then
        echo "[ChomiamOS] Déploiement des favoris COSMIC par défaut..."
        ${pkgs.coreutils}/bin/cp -f "${cosmicFavoritesJson}" "$COSMIC_FAV_DIR/favorites"
        ${pkgs.coreutils}/bin/chmod 644 "$COSMIC_FAV_DIR/favorites"
      fi
      ''}

      ${lib.optionalString enableCinnamon ''
      # Initialisation Cinnamon (dconf)
      if [ -x "${pkgs.dconf}/bin/dconf" ]; then
        echo "[ChomiamOS] Déploiement des réglages Cinnamon par défaut (fond d'écran, thème, favoris)..."
        ${pkgs.dconf}/bin/dconf load / < "${cinnamonDefaultsIni}" || true
      fi
      ''}

      ${pkgs.coreutils}/bin/touch "$SENTINEL"
      echo "[ChomiamOS] Interface utilisateur initialisée avec succès."
    else
      echo "[ChomiamOS] Bureau déjà initialisé ($SENTINEL présent)."
      echo "Vos personnalisations sont préservées."
      echo "Pour forcer la restauration des valeurs d'usine : chomiamos-desktop-setup --force"
    fi
  '';

  resetScript = pkgs.writeShellScriptBin "chomiamos-reset-desktop" ''
    set -euo pipefail
    echo "============================================================"
    echo " 🖥️  ChomiamOS : Réinitialisation du Bureau"
    echo "============================================================"
    echo "Cette action va rétablir les réglages d'usine de l'interface"
    echo "(fond d'écran, extensions activées, dock et thème officiel)."
    echo ""
    read -r -p "Voulez-vous continuer ? [o/N] " response
    case "$response" in
      [oO][uU][iI]|[oO])
        ${setupScript}/bin/chomiamos-desktop-setup --force
        ;;
      *)
        echo "Opération annulée."
        exit 0
        ;;
    esac
  '';

in
{
  # =========================================================================
  # 4. INTÉGRATION SYSTÈME & AUTOMATISATION AU PREMIER DÉMARRAGE
  # =========================================================================

  # Outils accessibles en ligne de commande pour l'utilisateur
  environment.systemPackages = [
    setupScript
    resetScript
    catppuccinTheme
    pkgs.catppuccin-cursors.mochaLavender
  ];

  # Thème système global GTK4 & GTK3 (Fallback XDG pour Libadwaita et toutes les sessions)
  environment.etc."xdg/gtk-4.0/gtk.css".source = "${catppuccinTheme}/share/themes/catppuccin-mocha-lavender-standard/gtk-4.0/gtk.css";
  environment.etc."xdg/gtk-4.0/gtk-dark.css".source = "${catppuccinTheme}/share/themes/catppuccin-mocha-lavender-standard/gtk-4.0/gtk-dark.css";
  environment.etc."xdg/gtk-4.0/assets".source = "${catppuccinTheme}/share/themes/catppuccin-mocha-lavender-standard/gtk-4.0/assets";
  environment.etc."xdg/gtk-3.0/gtk.css".source = "${catppuccinTheme}/share/themes/catppuccin-mocha-lavender-standard/gtk-3.0/gtk.css";
  environment.etc."xdg/gtk-3.0/gtk-dark.css".source = "${catppuccinTheme}/share/themes/catppuccin-mocha-lavender-standard/gtk-3.0/gtk-dark.css";
  environment.etc."xdg/gtk-3.0/assets".source = "${catppuccinTheme}/share/themes/catppuccin-mocha-lavender-standard/gtk-3.0/assets";

  # Dconf global activé
  programs.dconf.enable = lib.mkDefault true;

  # Service utilisateur Systemd exécuté au démarrage de la session graphique
  systemd.user.services.chomiamos-desktop-setup = {
    description = "ChomiamOS Desktop First-Boot Provisioning";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${setupScript}/bin/chomiamos-desktop-setup";
    };
  };

  # Autostart XDG complémentaire pour garantir l'exécution à l'ouverture de session
  environment.etc."xdg/autostart/chomiamos-desktop-setup.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=ChomiamOS Desktop Setup
    Exec=${setupScript}/bin/chomiamos-desktop-setup
    OnlyShowIn=GNOME;COSMIC;X-Cinnamon;Cinnamon;
    NoDisplay=true
    X-GNOME-Autostart-Phase=Initialization
  '';
}
