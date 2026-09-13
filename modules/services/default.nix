{ ... }:

{
  # =========================================================================
  # 🔌 POINT D'ENTRÉE DES SERVICES SYSTÈME & APPLICATIONS
  # Importation modulaire inconditionnelle : chaque service est activable
  # individuellement via config.chomiamos.services.<service>.enable
  # =========================================================================
  imports = [
    ./blender.nix
    ./davinci-resolve.nix
    ./flatpak.nix
    ./godot.nix
    ./neovim.nix
    ./nix-ld.nix
    ./obs.nix
    ./omniroute.nix
    ./podman.nix
    ./samba.nix
    ./virt-manager.nix
  ];
}
