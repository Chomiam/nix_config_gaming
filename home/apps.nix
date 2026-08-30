{ pkgs, ... }:

{
  # =========================================================================
  # 📦 PAQUETS UTILISATEUR & PARAMÈTRES D'ENVIRONNEMENT HOME-MANAGER
  # =========================================================================

  # Polices d'écriture utilisateur
  home.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
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
    TERMINAL = "kitty";
  };

}
