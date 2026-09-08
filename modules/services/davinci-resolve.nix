{ config, pkgs, lib, ... }:

let
  cfg = config.chomiamos.services.davinciResolve.version;
  gpu = config.chomiamos.hardware.gpu;

  # Choix du paquet DaVinci Resolve selon le paramètre chomiamos
  davinciPkg =
    if cfg == "studio" then pkgs.davinci-resolve-studio
    else if cfg == "free" then pkgs.davinci-resolve
    else null;
in
{
  # =========================================================================
  # 🎬 MODULE DAVINCI RESOLVE & SUPPORT ACCÉLÉRATION MATÉRIELLE (GPU)
  # =========================================================================

  config = lib.mkIf (cfg != "none" && davinciPkg != null) {

    # Installation du paquet DaVinci Resolve sélectionné (Gratuit ou Studio)
    environment.systemPackages = [ davinciPkg ];

    # Variables d'environnement nécessaires pour la stabilité et la détection GPU
    environment.sessionVariables = {
      # DaVinci Resolve utilise Qt et requiert XWayland pour éviter les problèmes d'affichage sous Wayland
      QT_QPA_PLATFORM = "xcb";
    } // (lib.optionalAttrs (gpu == "amd") {
      # Active la prise en charge des GPU AMD Polaris / Vega sur le runtime ROCm
      ROC_ENABLE_PRE_VEGA = "1";
    });

    # Configuration des paquets OpenCL / Calcul pour l'accélération matérielle GPU
    hardware.graphics = {
      enable = true;
      extraPackages = with pkgs;
        if gpu == "amd" then [
          rocmPackages.clr.icd # Runtime OpenCL ROCm officiel pour AMD Radeon
        ]
        else if gpu == "intel" then [
          intel-compute-runtime # Runtime OpenCL NEO pour Intel iGPU/dGPU
          intel-media-driver
        ]
        else [];
    };

    # Activation spécifique OpenCL du pilote noyau AMDGPU si GPU AMD
    hardware.amdgpu.opencl.enable = lib.mkIf (gpu == "amd") true;

    # Avertissement système si l'utilisateur essaie de lancer DaVinci sur du matériel Nvidia Legacy (470)
    warnings = lib.optional (gpu == "nvidia-legacy")
      "DaVinci Resolve nécessite CUDA 11+ (pilote NVIDIA 525+). Le pilote Nvidia Legacy (470) risque de bloquer l'initialisation de DaVinci Resolve.";
  };
}
