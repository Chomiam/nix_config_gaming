{ pkgs, vars, ... }:

{
  # =========================================================================
  # 🏠 POINT D'ENTRÉE HOME MANAGER UTILISATEUR
  # =========================================================================

  imports = [
    ./kitty.nix
    ./catppuccin.nix
    ./gtk-theme.nix
    ./fastfetch.nix
    ./apps.nix
  ];

  # Informations Utilisateur depuis vars.nix
  home = {
    username = vars.user.username;
    homeDirectory = vars.user.homeDirectory;
    stateVersion = vars.stateVersion;

    # 🧹 Nettoyage automatique des anciens fichiers .backup avant activation
    # Évite l'erreur "would be clobbered by backing up" de Home Manager
    activation.cleanupBackups = {
      before = [ "checkLinkTargets" ];
      after = [];
      data = ''
        echo "🧹 Nettoyage des anciens fichiers .backup Home Manager..."
        find "${vars.user.homeDirectory}" -maxdepth 1 -name "*.backup" -type f -delete 2>/dev/null || true
        find "${vars.user.homeDirectory}/.config" -maxdepth 3 -name "*.backup" -type f -delete 2>/dev/null || true
      '';
    };
  };

  programs.home-manager.enable = true;
}
