{ config, lib, pkgs, ... }:

{
  # =========================================================================
  # 🔴 PROFIL GPU : AMD RADEON
  # =========================================================================

  config = lib.mkIf (config.chomiamos.hardware.gpu == "amd") {
    # Utilise le noyau Zen optimisé pour le gaming et pré-compilé sur Hydra
    boot.kernelPackages = pkgs.linuxPackages_zen;

    # Prise en charge OpenCL AMD (ROCm)
    hardware.amdgpu.opencl.enable = true;

    # Graphiques Vulkan, VA-API & 32-bit (Steam)
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        vkbasalt
        libva
        rocmPackages.clr.icd # Runtime OpenCL AMD officiel
      ];
    };
  };
}
