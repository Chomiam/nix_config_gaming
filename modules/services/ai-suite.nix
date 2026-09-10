{ config, pkgs, lib, ... }:

let
  cfg = config.chomiamos.services.aiSuite;
  gpu = config.chomiamos.hardware.gpu;

  # Sélection du paquet Ollama adapté au GPU configuré
  ollamaPkg =
    if gpu == "amd" then pkgs.ollama-rocm
    else if gpu == "nvidia" || gpu == "nvidia-legacy" then pkgs.ollama-cuda
    else pkgs.ollama;

  # Variables d'environnement d'Ollama (VRAM keep-alive + GPU GFX Override AMD)
  ollamaEnv = {
    OLLAMA_KEEP_ALIVE = cfg.keepAlive;
  } // (lib.optionalAttrs (gpu == "amd" && cfg.rocmOverrideGfx != "") {
    HSA_OVERRIDE_GFX_VERSION = cfg.rocmOverrideGfx;
  });
in
{
  # =========================================================================
  # 🤖 MODULE IA LOCALE : OLLAMA + SEARXNG + OPEN-WEBUI
  # =========================================================================

  config = lib.mkIf cfg.enable {

    # 1. 🦙 Service Ollama avec accélération GPU dynamique (AMD ROCm / Nvidia CUDA / Intel / CPU)
    services.ollama = {
      enable = true;
      package = ollamaPkg;
      rocmOverrideGfx = lib.mkIf (gpu == "amd" && cfg.rocmOverrideGfx != "") cfg.rocmOverrideGfx;
      environmentVariables = ollamaEnv;
    };

    # 2. 🔍 Service SearXNG : Moteur de recherche local privé pour l'agent IA
    services.searx = {
      enable = true;
      uwsgiConfig = {
        http = "127.0.0.1:${toString cfg.searxPort}";
      };
      settings = {
        server = {
          port = cfg.searxPort;
          bind_address = "127.0.0.1";
          secret_key = "secret_key_chomiam_local_ia_searxng";
        };
        search = {
          safe_search = 0;
          formats = [ "html" "json" ]; # Le format JSON est indispensable pour l'extraction RAG
        };
      };
    };

    # 3. 🌐 Service Open-WebUI : Interface graphique & Agent connecté à Ollama et SearXNG
    services.open-webui = {
      enable = true;
      port = cfg.openWebUiPort;
      host = if cfg.openFirewall then "0.0.0.0" else "127.0.0.1";
      openFirewall = cfg.openFirewall;
      environment = {
        OLLAMA_BASE_URL = "http://127.0.0.1:11434";
        ENABLE_RAG_WEB_SEARCH = "True";
        RAG_WEB_SEARCH_ENGINE = "searxng";
        SEARXNG_QUERY_URL = "http://127.0.0.1:${toString cfg.searxPort}/search?q=<query>";
      };
    };

    # Prise en charge des drivers ROCm pour GPU AMD
    hardware.graphics = lib.mkIf (gpu == "amd") {
      enable = true;
      extraPackages = with pkgs; [
        rocmPackages.clr.icd
      ];
    };
    hardware.amdgpu.opencl.enable = lib.mkIf (gpu == "amd") true;
  };
}
