{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.chomiamos.services.ollama;
  gpu = config.chomiamos.hardware.gpu;

  # Type d'accélération effectif calculé selon le GPU actif ou le choix manuel
  effectiveAcceleration =
    if cfg.acceleration != "auto" then
      cfg.acceleration
    else if gpu == "amd" then
      "rocm"
    else if gpu == "nvidia" then
      "cuda"
    else if gpu == "nvidia-legacy" then
      "cpu"
    else
      "cpu";

  # Sélection modulaire du package Ollama selon l'accélération effective
  ollamaPackage =
    if effectiveAcceleration == "rocm" then
      pkgs.ollama-rocm
    else if effectiveAcceleration == "cuda" then
      pkgs.ollama-cuda
    else
      pkgs.ollama;

  rocmGfxOverride =
    if (effectiveAcceleration == "rocm") then cfg.rocmOverrideGfx else null;
in
{
  # =========================================================================
  # 🦙 SERVICE OLLAMA MODULAIRE (LLM LOCAL & ACCÉLÉRATION GPU DYNAMIQUE)
  # Détection et accélération matérielle automatique selon le GPU actif :
  # - AMD Radeon    -> ROCm (avec override HSA_OVERRIDE_GFX_VERSION si besoin)
  # - NVIDIA        -> CUDA (paquet ollama-cuda)
  # - NVIDIA Legacy -> CPU avec avertissement de stabilité
  # - Intel / VM    -> CPU standard
  # =========================================================================

  config = lib.mkIf cfg.enable {
    # Avertissement si le GPU est Nvidia Legacy (pilote 470 incompatible avec CUDA moderne)
    warnings =
      lib.optional (gpu == "nvidia-legacy" && cfg.acceleration == "auto")
        "Ollama : Le pilote Nvidia Legacy (470) ne prend pas en charge les versions récentes de CUDA. Ollama a basculé automatiquement en mode CPU pour préserver la stabilité du système.";

    # Prise en charge OpenCL AMD si ROCm est actif
    hardware.amdgpu.opencl.enable = lib.mkIf (effectiveAcceleration == "rocm") true;

    services.ollama = {
      enable = true;
      host = "127.0.0.1";
      port = cfg.port;

      # Package accéléré GPU modulaire (ROCm / CUDA / CPU)
      package = ollamaPackage;

      # Override GFX ROCm pour AMD Radeon si applicable
      rocmOverrideGfx = rocmGfxOverride;

      # Téléchargement déclaratif automatique du modèle spécifié au démarrage
      loadModels = lib.optional (cfg.model != null && cfg.model != "") cfg.model;
    };
  };
}
