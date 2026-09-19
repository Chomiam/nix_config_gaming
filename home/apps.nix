{ pkgs, vars, ... }:

let
  configuredTerminal = vars.terminal or "kitty";
in
{
  # =========================================================================
  # 📦 PAQUETS UTILISATEUR & PARAMÈTRES D'ENVIRONNEMENT HOME-MANAGER
  # =========================================================================

  # Polices d'écriture utilisateur & Émulateurs de terminaux
  home.packages = with pkgs; [
    nerd-fonts.jetbrains-mono

    # Émulateurs de terminaux supportés
    kitty
    gnome-terminal
    kdePackages.konsole
    alacritty
    cosmic-term
  ];

  # Traitement Audio (EasyEffects)
  services.easyeffects.enable = true;

  # Client Mail Thunderbird (Langue par défaut en Français via Stratégie Globale)
  programs.thunderbird = {
    enable = true;
    profiles.default = {
      isDefault = true;
    };
    policies = {
      RequestedLocales = [ "fr" ];
    };
  };

  # Variables d'environnement de session
  home.sessionVariables = {
    TERMINAL = configuredTerminal;
  };
}
