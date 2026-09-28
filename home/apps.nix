{ pkgs, vars, ... }:

let
  configuredTerminal = vars.terminal or "kitty";

  selectedTerminalPackage =
    if configuredTerminal == "kitty" then pkgs.kitty
    else if configuredTerminal == "alacritty" then pkgs.alacritty
    else if configuredTerminal == "gnome-terminal" then pkgs.gnome-terminal
    else if configuredTerminal == "konsole" then pkgs.kdePackages.konsole
    else if configuredTerminal == "cosmic-term" then pkgs.cosmic-term
    else pkgs.kitty;
in
{
  # =========================================================================
  # 📦 PAQUETS UTILISATEUR & PARAMÈTRES D'ENVIRONNEMENT HOME-MANAGER
  # =========================================================================

  # Polices d'écriture utilisateur & Émulateur de terminal sélectionné exclusivement
  home.packages = [
    pkgs.nerd-fonts.jetbrains-mono
    selectedTerminalPackage
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
