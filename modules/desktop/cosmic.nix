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

    # Paquets spécifiques COSMIC installés pour l'utilisateur principal
    users.users."${username}".packages = with pkgs; [
      cosmic-icons
    ];

    # =========================================================================
    # 🛡️ FIABILISATION DU GREETER (GREETD / COSMIC-GREETER) & HANDOFF PLYMOUTH
    # =========================================================================

    # Configuration et fiabilisation de greetd pour cosmic-greeter
    # Résout les écrans noirs post-Plymouth (handoff Plymouth → cosmic-comp)
    # et injecte les variables requises dans l'environnement du service système.
    systemd.services.greetd = {
      environment = {
        COSMIC_DATA_CONTROL_ENABLED = "1";
        COSMIC_DISABLE_DIRECT_SCANOUT = "1";
        XKB_DEFAULT_LAYOUT = cfg.keyboard.layout;
        XKB_DEFAULT_VARIANT = cfg.keyboard.variant;
      };

      # 🛡️ Garantit les permissions complètes de l'utilisateur cosmic-greeter avant chaque démarrage
      preStart = ''
        ${pkgs.coreutils}/bin/mkdir -p /var/lib/cosmic-greeter/.config/cosmic/com.system76.CosmicComp/v1 /run/cosmic-greeter
        ${pkgs.coreutils}/bin/chown -R cosmic-greeter:cosmic-greeter /var/lib/cosmic-greeter /run/cosmic-greeter
        ${pkgs.coreutils}/bin/chmod 750 /var/lib/cosmic-greeter
      '';

      # Redémarrage automatique avec temporisation pour éviter l'échec immédiat (start-limit-hit)
      serviceConfig = {
        Restart = lib.mkForce "always";
        RestartSec = "2s";
      };

      # Ordre de démarrage strict et tolérance de redémarrage (10 essais en 30s)
      unitConfig = {
        StartLimitBurst = 10;
        StartLimitIntervalSec = "30s";
        After = [
          "plymouth-quit-wait.service"
          "plymouth-quit.service"
          "systemd-user-sessions.service"
        ];
      };
    };

    # Permissions complètes d'accès aux périphériques DRM et d'entrée pour le greeter (VM & Bare-metal)
    users.users.cosmic-greeter.extraGroups = [
      "video"
      "render"
      "input"
    ];

    # =========================================================================
    # ⌨️ CONTOURNE DU LAYOUT CLAVIER ET FIX PRESSE-PAPIER (CLIPBOARD)
    # =========================================================================

    # Variables d'environnement pour la session interactive COSMIC / Wayland
    environment.sessionVariables = {
      XKB_DEFAULT_LAYOUT = cfg.keyboard.layout;
      XKB_DEFAULT_VARIANT = cfg.keyboard.variant;

      # 🔓 Preserving Clipboard: Active le protocole Data Control pour les gestionnaires de presse-papier
      COSMIC_DATA_CONTROL_ENABLED = "1";

      # 🛡️ Désactive le direct scanout pour éviter les pertes de signal / artefacts
      # sur les GPU AMD RDNA 2/3 lors de l'initialisation de cosmic-comp
      COSMIC_DISABLE_DIRECT_SCANOUT = "1";
    };

    # Correctif Permissions déclaratif et XKB explicite pour le compositeur du greeter
    systemd.tmpfiles.rules = [
      "d /var/lib/cosmic-greeter 0750 cosmic-greeter cosmic-greeter -"
      "d /var/lib/cosmic-greeter/.config 0755 cosmic-greeter cosmic-greeter -"
      "d /var/lib/cosmic-greeter/.config/cosmic 0755 cosmic-greeter cosmic-greeter -"
      "d /var/lib/cosmic-greeter/.config/cosmic/com.system76.CosmicComp 0755 cosmic-greeter cosmic-greeter -"
      "d /var/lib/cosmic-greeter/.config/cosmic/com.system76.CosmicComp/v1 0755 cosmic-greeter cosmic-greeter -"
      "d /run/cosmic-greeter 0755 cosmic-greeter cosmic-greeter -"
      "Z /var/lib/cosmic-greeter 0750 cosmic-greeter cosmic-greeter -"
      "Z /run/cosmic-greeter 0755 cosmic-greeter cosmic-greeter -"
      "f+ /var/lib/cosmic-greeter/.config/cosmic/com.system76.CosmicComp/v1/xkb_config 0644 cosmic-greeter cosmic-greeter - (\n    rules: \"\",\n    model: \"\",\n    layout: \"${cfg.keyboard.layout}\",\n    variant: \"${cfg.keyboard.variant}\",\n    options: None,\n)"
    ];
  };
}
