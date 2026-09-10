{ config, lib, pkgs, inputs, browserInfo, ... }:

let
  cfg = config.chomiamos;
  enableCosmic = cfg.desktop.env == "cosmic" || cfg.desktop.env == "both";
  username = cfg.user.username;
  # Source des paquets COSMIC 1.5.0 depuis nixpkgs-unstable
  pkgs-unstable = inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in
{
  # =========================================================================
  # 🚀 ENVIRONNEMENT DE BUREAU : COSMIC DESKTOP 1.5+ (NIXPKGS UNSTABLE)
  # =========================================================================

  config = lib.mkIf enableCosmic {
    # Overlay ciblé : Remplacer l'ensemble des paquets COSMIC par la version 1.5.0 de nixpkgs-unstable
    nixpkgs.overlays = [
      (final: prev: {
        cosmic-app-library = pkgs-unstable.cosmic-app-library;
        cosmic-applibrary = pkgs-unstable.cosmic-app-library;
        cosmic-applets = pkgs-unstable.cosmic-applets;
        cosmic-bg = pkgs-unstable.cosmic-bg;
        cosmic-comp = pkgs-unstable.cosmic-comp;
        cosmic-edit = pkgs-unstable.cosmic-edit;
        cosmic-files = pkgs-unstable.cosmic-files;
        cosmic-greeter = pkgs-unstable.cosmic-greeter;
        cosmic-icons = pkgs-unstable.cosmic-icons;
        cosmic-idle = pkgs-unstable.cosmic-idle;
        cosmic-initial-setup = pkgs-unstable.cosmic-initial-setup;
        cosmic-launcher = pkgs-unstable.cosmic-launcher;
        cosmic-media-player = pkgs-unstable.cosmic-media-player;
        cosmic-notifications = pkgs-unstable.cosmic-notifications;
        cosmic-osd = pkgs-unstable.cosmic-osd;
        cosmic-panel = pkgs-unstable.cosmic-panel;
        cosmic-player = pkgs-unstable.cosmic-player;
        cosmic-protocols = pkgs-unstable.cosmic-protocols;
        cosmic-randr = pkgs-unstable.cosmic-randr;
        cosmic-reader = pkgs-unstable.cosmic-reader;
        cosmic-screenshot = pkgs-unstable.cosmic-screenshot;
        cosmic-session = pkgs-unstable.cosmic-session;
        cosmic-settings = pkgs-unstable.cosmic-settings;
        cosmic-settings-daemon = pkgs-unstable.cosmic-settings-daemon;
        cosmic-sound-theme = pkgs-unstable.cosmic-sound-theme;
        cosmic-store = pkgs-unstable.cosmic-store;
        cosmic-term = pkgs-unstable.cosmic-term;
        cosmic-wallpapers = pkgs-unstable.cosmic-wallpapers;
        cosmic-workspaces = pkgs-unstable.cosmic-workspaces-epoch;
        cosmic-workspaces-epoch = pkgs-unstable.cosmic-workspaces-epoch;
        libcosmicAppHook = pkgs-unstable.libcosmicAppHook;
        xdg-desktop-portal-cosmic = pkgs-unstable.xdg-desktop-portal-cosmic;
      })
    ];

    # Activation du bureau COSMIC et du gestionnaire de connexion cosmic-greeter
    services.desktopManager.cosmic.enable = true;
    services.displayManager.cosmic-greeter.enable = true;

    # Exclusion d'applications secondaires non indispensables
    environment.cosmic.excludePackages = with pkgs; [
      cosmic-edit
    ];

    # Paquets spécifiques COSMIC et applets communautaires installés pour l'utilisateur principal
    users.users."${username}".packages = with pkgs; [
      cosmic-icons

      # 🧩 Applets de la communauté COSMIC (ext-cosmic-applets-flake)
      inputs.ext-cosmic-applets.packages.${pkgs.stdenv.hostPlatform.system}.cosmic-ext-applet-clipboard-manager
      inputs.ext-cosmic-applets.packages.${pkgs.stdenv.hostPlatform.system}.minimon-applet
    ];

    # =========================================================================
    # ⌨️ CONTOURNE DU LAYOUT CLAVIER ET FIX PRESSE-PAPIER (CLIPBOARD)
    # =========================================================================

    # Variables d'environnement pour COSMIC / Wayland
    environment.sessionVariables = {
      XKB_DEFAULT_LAYOUT = "fr";
      XKB_DEFAULT_VARIANT = "";

      # 🔓 Preserving Clipboard: Active le protocole Data Control pour les gestionnaires de presse-papier
      COSMIC_DATA_CONTROL_ENABLED = "1";
    };

    # Correctif B : Fichier de configuration XKB explicite pour le compositeur du greeter
    systemd.tmpfiles.rules = [
      "d /var/lib/cosmic-greeter/.config/cosmic/com.system76.CosmicComp/v1 0755 cosmic-greeter cosmic-greeter -"
      "f+ /var/lib/cosmic-greeter/.config/cosmic/com.system76.CosmicComp/v1/xkb_config 0644 cosmic-greeter cosmic-greeter - (\n    rules: \"\",\n    model: \"\",\n    layout: \"fr\",\n    variant: \"\",\n    options: None,\n)"
    ];
  };
}
