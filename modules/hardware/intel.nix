{ config, lib, pkgs, ... }:

{
  # =========================================================================
  # 🔵 PROFIL GPU : INTEL (iGPU / Arc dGPU)
  # =========================================================================

  config = lib.mkIf (config.chomiamos.hardware.gpu == "intel") {
    # Utilise le dernier noyau XanMod optimisé
    boot.kernelPackages = pkgs.linuxPackages_xanmod_latest;

    # Graphiques, VA-API Intel Media Driver & OpenCL Compute
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        intel-media-driver # Pilote moderne pour Broadwell et plus récent (iHD)
        intel-vaapi-driver # Pilote pour GPU Intel plus anciens (Gen 7 / Haswell et antérieurs)
        libva
        libva-utils
        intel-compute-runtime # OpenCL / OneAPI
      ];
      extraPackages32 = with pkgs.pkgsi686Linux; [
        intel-media-driver
        intel-vaapi-driver
        libva
      ];
    };
  };
}
