{ ... }:

{
  # =========================================================================
  # 🎛️ SECTEUR HARDWARE : PROFILS MATÉRIELS & PILOTES GPU
  # Importation inconditionnelle : chaque profil s'active selon
  # config.chomiamos.hardware.gpu
  # =========================================================================
  imports = [
    ./amd.nix
    ./nvidia.nix
    ./nvidia-legacy.nix
    ./intel.nix
    ./steering-wheels.nix
  ];
}
