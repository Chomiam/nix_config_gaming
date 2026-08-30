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
  };

  programs.home-manager.enable = true;
}
