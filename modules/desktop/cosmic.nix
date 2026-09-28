{ config, lib, pkgs, inputs, browserInfo, ... }:

let
  cfg = config.chomiamos;
  enableCosmic = cfg.desktop.env == "cosmic" || cfg.desktop.env == "both";
  username = cfg.user.username;
in
{
  # =========================================================================
  # 🚀 ENVIRONNEMENT DE BUREAU : COSMIC DESKTOP (FLAKE COMMUNAUTAIRE)
  # Source : github:lilyinstarlight/nixos-cosmic
  # =========================================================================

  config = lib.mkIf enableCosmic {
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
