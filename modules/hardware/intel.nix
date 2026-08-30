{ pkgs, ... }:

{
  # =========================================================================
  # 🔵 PROFIL GPU : INTEL (iGPU / Arc dGPU)
  # =========================================================================

  # Utilise le dernier noyau XanMod optimisé
  boot.kernelPackages = pkgs.linuxPackages_xanmod_latest;

  # Graphiques, VA-API Intel Media Driver & OpenCL Compute
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      intel-media-driver # Pilote moderne pour Broadwell et plus récent
      libva
      libva-utils
      intel-compute-runtime # OpenCL / OneAPI
    ];
  };
}
