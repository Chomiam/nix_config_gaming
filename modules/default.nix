{ ... }:

{
  # =========================================================================
  # 📦 ARCHITECTURE MODULAIRE CHOMIAMOS
  # Importe sans condition l'ensemble des définitions et modules.
  # L'activation de chaque composant est contrôlée par les options chomiamos.*
  # =========================================================================
  imports = [
    ./options.nix
    ./core
    ./hardware
    ./desktop
    ./gaming
    ./services
  ];
}
