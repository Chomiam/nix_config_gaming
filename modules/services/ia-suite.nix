{ config, pkgs, lib, ... }:

let
  cfg = config.chomiamos.services.iaSuite;
  gpu = config.chomiamos.hardware.gpu;

  # Sélection du package Ollama selon l'accélération demandée ou le GPU actif
  ollamaPackage =
    if cfg.ollama.acceleration == "rocm" then pkgs.ollama-rocm
    else if cfg.ollama.acceleration == "cuda" then pkgs.ollama-cuda
    else if cfg.ollama.acceleration == "vulkan" then pkgs.ollama-vulkan
    else if cfg.ollama.acceleration == "cpu" then pkgs.ollama-cpu
    else
      # Mode "auto" : détection conditionnelle selon config.chomiamos.hardware.gpu
      if gpu == "amd" then pkgs.ollama-rocm
      else if gpu == "nvidia" then pkgs.ollama-cuda
      else if gpu == "nvidia-legacy" then pkgs.ollama-cpu
      else if gpu == "intel" then pkgs.ollama-vulkan
      else pkgs.ollama-cpu;

  # Définition de l'override GFX pour ROCm si configuré
  rocmGfxOverride =
    if (gpu == "amd" || cfg.ollama.acceleration == "rocm") then cfg.ollama.rocmOverrideGfx
    else null;
in
{
  # =========================================================================
  # 🧠 SUITE IA LOCALE (IA-SUITE)
  # - Ollama : Serveur d'inférence LLM local accéléré par GPU (ROCm/CUDA/Vulkan)
  # - Open WebUI : Interface Web conversationnelle moderne (type ChatGPT)
  # - Hermes Agent : Agent d'automatisation et de raisonnement autonome (Nous Research)
  # =========================================================================

  config = lib.mkIf cfg.enable {

    # 1. 🦭 Activation automatique du runtime Podman si Open WebUI ou Hermes sont activés
    chomiamos.services.podman.enable = lib.mkIf (cfg.openWebUI.enable || cfg.hermes.enable) true;

    # 2. 🦙 Service natif Ollama avec accélération GPU conditionnelle
    services.ollama = lib.mkIf cfg.ollama.enable {
      enable = true;
      package = ollamaPackage;
      port = cfg.ollama.port;
      host = if cfg.openFirewall then "0.0.0.0" else "127.0.0.1";
      openFirewall = false; # Géré centralement ci-dessous
      rocmOverrideGfx = rocmGfxOverride;
      loadModels = cfg.ollama.models;
    };

    # Activation spécifique OpenCL du noyau pour GPU AMD si Ollama utilise ROCm
    hardware.amdgpu.opencl.enable = lib.mkIf (cfg.ollama.enable && (gpu == "amd" || cfg.ollama.acceleration == "rocm")) true;

    # Avertissement si le GPU est Nvidia Legacy (pilote 470 incompatible avec CUDA 12)
    warnings = lib.optional (cfg.ollama.enable && gpu == "nvidia-legacy" && cfg.ollama.acceleration == "auto")
      "IA-Suite : Le pilote Nvidia Legacy (470) ne prend pas en charge CUDA 12. Ollama a basculé automatiquement en mode CPU pour préserver la stabilité du système.";

    # 3. 🌐 Conteneur OCI Open WebUI sous Podman
    virtualisation.oci-containers.containers.open-webui = lib.mkIf cfg.openWebUI.enable {
      image = cfg.openWebUI.image;
      autoStart = true;
      extraOptions = [
        "--network=host"
        "--stop-timeout=40"
      ];
      volumes = [
        "open-webui-data:/app/backend/data"
      ];
      environment = {
        PORT = toString cfg.openWebUI.port;
        WEBUI_HOST = if cfg.openFirewall then "0.0.0.0" else "127.0.0.1";
        OLLAMA_BASE_URL = "http://127.0.0.1:${toString cfg.ollama.port}";
        ENABLE_OLLAMA_API = if cfg.ollama.enable then "True" else "False";
        OPENAI_API_BASE_URLS = if cfg.hermes.enable then "http://127.0.0.1:${toString cfg.hermes.apiPort}/v1" else "";
        OPENAI_API_KEYS = if cfg.hermes.enable then "hermes" else "";
        ANONYMIZED_TELEMETRY = "False";
        DO_NOT_TRACK = "True";
        SCARF_NO_ANALYTICS = "True";
      };
    };

    # 4. 🤖 Conteneur OCI Agent IA Hermes (Nous Research) sous Podman
    virtualisation.oci-containers.containers.hermes-agent = lib.mkIf cfg.hermes.enable {
      image = cfg.hermes.image;
      autoStart = true;
      cmd = [ "gateway" "run" ];
      extraOptions = [
        "--network=host"
        "--stop-timeout=40"
      ];
      volumes = [
        "hermes-agent-data:/opt/data"
      ];
      environment = {
        HERMES_HOME = "/opt/data";
        HERMES_WRITE_SAFE_ROOT = "/opt/data";
        HERMES_DASHBOARD = "1";
        HERMES_DASHBOARD_PORT = toString cfg.hermes.dashboardPort;
        HERMES_DASHBOARD_BASIC_AUTH_USERNAME = cfg.hermes.dashboardUsername;
        HERMES_DASHBOARD_BASIC_AUTH_PASSWORD = cfg.hermes.dashboardPassword;
        HERMES_DASHBOARD_BASIC_AUTH_SECRET = "chomiamos-hermes-session-secret-key-2026";
        API_SERVER_ENABLED = "true";
        API_SERVER_PORT = toString cfg.hermes.apiPort;
        API_SERVER_KEY = cfg.hermes.apiKey;
        OPENAI_BASE_URL = "http://127.0.0.1:${toString cfg.ollama.port}/v1";
        OPENAI_API_KEY = "ollama";
        OLLAMA_BASE_URL = "http://127.0.0.1:${toString cfg.ollama.port}";
        HERMES_MODEL = cfg.hermes.defaultModel;
      };
    };

    # 5. 🛡️ Pare-feu réseau déclaratif
    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall (
      lib.optional cfg.ollama.enable cfg.ollama.port
      ++ lib.optional cfg.openWebUI.enable cfg.openWebUI.port
      ++ lib.optionals cfg.hermes.enable [ cfg.hermes.apiPort cfg.hermes.dashboardPort ]
    );

    # 6. 🖥️ Outils et raccourcis dans le menu d'applications GNOME / Bureau
    environment.systemPackages = [
      # Outil CLI Hugging Face Hub (expose huggingface-cli et hf dans le PATH sans collision avec Python système)
      (pkgs.python313Packages.toPythonApplication pkgs.python313Packages.huggingface-hub)

      (lib.mkIf cfg.openWebUI.enable (pkgs.makeDesktopItem {
        name = "open-webui";
        desktopName = "Open WebUI";
        comment = "Interface Web IA locale (Ollama & Hermes)";
        exec = "xdg-open http://localhost:${toString cfg.openWebUI.port}";
        icon = "chat-message-new";
        categories = [ "Development" "Utility" ];
      }))

      (lib.mkIf cfg.hermes.enable (pkgs.makeDesktopItem {
        name = "hermes-agent";
        desktopName = "Hermes Agent";
        comment = "Tableau de bord de l'agent IA Hermes (Nous Research)";
        exec = "xdg-open http://localhost:${toString cfg.hermes.dashboardPort}";
        icon = "system-run";
        categories = [ "Development" "Utility" ];
      }))
    ];

    # 7. 🔌 Autorisation sudo sans mot de passe pour l'agent Hermes via protocole ACP (VS Code, etc.)
    security.sudo.extraRules = lib.mkIf cfg.hermes.enable [
      {
        users = [ config.chomiamos.user.username ];
        commands = [
          {
            command = "/run/current-system/sw/bin/podman exec -i hermes-agent hermes acp";
            options = [ "NOPASSWD" ];
          }
          {
            command = "${pkgs.podman}/bin/podman exec -i hermes-agent hermes acp";
            options = [ "NOPASSWD" ];
          }
        ];
      }
    ];
  };
}

