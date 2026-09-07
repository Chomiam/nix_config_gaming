{ config, pkgs, lib, inputs, vars, ... }:

{
  # =========================================================================
  # 🖥️ HÔTE DESKTOP : ASSEMBLAGE DES MODULES NIXOS
  # =========================================================================

  imports = [
    # Configuration matérielle spécifique à la machine
    ./hardware-configuration.nix
    ./mount.nix

    # Modules matériels GPU dynamiques
    ../../modules/hardware

    # Core & Utilisateurs
    ../../modules/core
    ../../modules/core/users.nix

    # Environnement Graphique (GNOME / COSMIC)
    ../../modules/desktop

    # Jeux & Compatibilité Gaming
    ../../modules/gaming

    # Services Système & Applications
    ../../modules/services/flatpak.nix
    ../../modules/services/docker.nix
    ../../modules/services/nix-ld.nix
    ../../modules/services/obs.nix
    ../../modules/services/neovim.nix
    ../../modules/services/davinci-resolve.nix
    ../../modules/services/godot.nix
    ../../modules/services/blender.nix
    ../../modules/services/ai-suite.nix
    ../../modules/services/gnome-boxes.nix
  ];
}
