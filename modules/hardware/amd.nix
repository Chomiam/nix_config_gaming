{ config, lib, pkgs, ... }:

{
  # =========================================================================
  # 🔴 PROFIL GPU : AMD RADEON
  # =========================================================================

  config = lib.mkIf (config.chomiamos.hardware.gpu == "amd") {
    # Utilise le noyau Zen optimisé pour le gaming et pré-compilé sur Hydra
    boot.kernelPackages = pkgs.linuxPackages_zen;

    # -----------------------------------------------------------------------
    # 🛡️ CORRECTIFS STABILITÉ AMDGPU (RDNA 2/3)
    # Résout la perte d'affichage juste avant le greeter COSMIC (cosmic-comp)
    # -----------------------------------------------------------------------

    # Early KMS : charge amdgpu dès l'initrd pour que le GPU soit
    # entièrement initialisé avant le lancement de cosmic-greeter
    boot.initrd.kernelModules = [ "amdgpu" ];

    # Paramètres kernel amdgpu :
    # - runpm=0   : Désactive le Runtime Power Management (BACO/BOCO)
    #               qui provoque des pertes de signal lors du handoff
    #               Plymouth → cosmic-comp sur RDNA 2/3
    # - dcdebugmask=0x410 : Désactive PSR (Panel Self Refresh) et IPS
    #               (Idle Power Saving) qui peuvent bloquer l'init du display
    boot.kernelParams = [
      "amdgpu.runpm=0"
      "amdgpu.dcdebugmask=0x410"
    ];

    # Assure la disponibilité du firmware AMD (microcode GPU, DCN, VCN)
    hardware.enableRedistributableFirmware = lib.mkDefault true;

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
