{ ... }:

{
  # =========================================================================
  # 🔌 POINT D'ENTRÉE DES SERVICES SYSTÈME & APPLICATIONS
  # Importation modulaire inconditionnelle : chaque service est activable
  # individuellement via config.chomiamos.services.<service>.enable
  # =========================================================================
  imports = [
    ./ai-suite.nix
    ./blender.nix
    ./davinci-resolve.nix
    ./docker.nix
    ./flatpak.nix
    ./godot.nix
    ./neovim.nix
    ./nix-ld.nix
    ./obs.nix
    ./samba.nix
    ./virt-manager.nix
  ];
}
