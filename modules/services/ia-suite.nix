{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.chomiamos.services.iaSuite;
  gpu = config.chomiamos.hardware.gpu;
  username = config.chomiamos.user.username;
  userHome = config.chomiamos.user.homeDirectory;

  # Type d'accélération effectif (calculé selon le choix manuel ou auto selon le GPU actif)
  effectiveAcceleration =
    if cfg.llamaCpp.acceleration != "auto" then
      cfg.llamaCpp.acceleration
    else if gpu == "amd" then
      "rocm"
    else if gpu == "nvidia" then
      "cuda"
    else if gpu == "intel" then
      "vulkan"
    else
      "cpu";

  # Sélection du package llama.cpp selon l'accélération effective
  llamaPackage =
    if effectiveAcceleration == "rocm" then
      pkgs.llama-cpp-rocm
    else if effectiveAcceleration == "cuda" then
      pkgs.llama-cpp.override { cudaSupport = true; }
    else if effectiveAcceleration == "vulkan" then
      pkgs.llama-cpp-vulkan
    else
      pkgs.llama-cpp;

  # Définition de l'override GFX pour ROCm si configuré
  rocmGfxOverride =
    if (effectiveAcceleration == "rocm") then cfg.llamaCpp.rocmOverrideGfx else null;
  effectiveModelsDir =
    if cfg.llamaCpp.modelsDir != null then
      cfg.llamaCpp.modelsDir
    else
      "${userHome}/models";
in
{
  # =========================================================================
  # 🧠 SUITE IA LOCALE (IA-SUITE)
  # - llama.cpp : Serveur d'inférence LLM local haute performance accéléré par GPU (ROCm/CUDA/Vulkan)
  # - Open WebUI : Interface Web conversationnelle moderne (type ChatGPT)
  # - Hermes Agent : Agent IA natif d'automatisation et de raisonnement autonome (Nous Research)
  # =========================================================================

  config = lib.mkIf cfg.enable {

    # 1. 🦭 Activation automatique du runtime Podman si Open WebUI est activé (Hermes et llama.cpp sont natifs)
    chomiamos.services.podman.enable = lib.mkIf cfg.openWebUI.enable true;

    # 2. 🦙 Service natif llama.cpp (llama-server) avec accélération GPU conditionnelle
    services.llama-cpp = lib.mkIf cfg.llamaCpp.enable {
      enable = true;
      package = llamaPackage;
      port = cfg.llamaCpp.port;
      host = if cfg.openFirewall then "0.0.0.0" else "127.0.0.1";
      openFirewall = false; # Géré centralement ci-dessous
      model = cfg.llamaCpp.model;
      modelsDir =
        if (cfg.llamaCpp.model == null && cfg.llamaCpp.hfRepo == null) then
          effectiveModelsDir
        else
          null;
      modelsPreset = cfg.llamaCpp.modelsPreset;

      # Paramètres d'inférence et optimisations GPU
      extraFlags =
        [
          "-c"
          (toString cfg.llamaCpp.contextLength)
          "--jinja" # Active le moteur de template Jinja pour le Function/Tool-Calling natif (Hermes, etc.)
        ]
        ++ lib.optionals (cfg.llamaCpp.gpuLayers > 0 && effectiveAcceleration != "cpu") [
          "-ngl"
          (toString cfg.llamaCpp.gpuLayers)
        ]
        ++ lib.optionals (cfg.llamaCpp.hfRepo != null) [
          "--hf-repo"
          cfg.llamaCpp.hfRepo
        ]
        ++ lib.optionals (cfg.llamaCpp.hfFile != null) [
          "--hf-file"
          cfg.llamaCpp.hfFile
        ]
        ++ lib.optionals (cfg.llamaCpp.alias != null) [
          "--alias"
          cfg.llamaCpp.alias
        ]
        ++ lib.optionals (cfg.llamaCpp.apiKey != null) [
          "--api-key"
          cfg.llamaCpp.apiKey
        ]
        ++ cfg.llamaCpp.extraFlags;
    };

    # Compléments pour le service systemd llama-cpp : exécution sous le compte utilisateur,
    # accès direct au dossier de modèles ~/models et au cache Hugging Face ~/.cache/huggingface
    systemd.services.llama-cpp = lib.mkIf cfg.llamaCpp.enable {
      serviceConfig = {
        DynamicUser = lib.mkForce false;
        User = username;
        Group = "users";
        ProtectHome = lib.mkForce false;
        ProtectSystem = lib.mkForce "full";
        PrivateUsers = lib.mkForce false;
        WorkingDirectory = lib.mkForce userHome;
        StateDirectory = lib.mkForce [ ];
        CacheDirectory = lib.mkForce [ ];
        Environment = lib.mkForce [
          "LLAMA_CACHE=${userHome}/.cache/llama-cpp"
          "HF_HOME=${userHome}/.cache/huggingface"
        ];
        # Accès direct aux périphériques GPU (/dev/kfd, /dev/dri/renderD*, /dev/nvidia*)
        SupplementaryGroups = [
          "render"
          "video"
        ];
        ExecStartPre = lib.mkForce "${pkgs.coreutils}/bin/mkdir -p ${effectiveModelsDir} ${userHome}/.cache/llama-cpp ${userHome}/.cache/huggingface/hub";
      };
      environment = {
        HOME = userHome;
        HF_HOME = "${userHome}/.cache/huggingface";
        LLAMA_CACHE = "${userHome}/.cache/llama-cpp";
      } // lib.optionalAttrs (rocmGfxOverride != null) {
        HSA_OVERRIDE_GFX_VERSION = rocmGfxOverride;
      };
    };

    # Activation spécifique OpenCL du noyau pour GPU AMD si llama.cpp utilise ROCm
    hardware.amdgpu.opencl.enable = lib.mkIf (
      cfg.llamaCpp.enable && effectiveAcceleration == "rocm"
    ) true;

    # Avertissement si le GPU est Nvidia Legacy (pilote 470 incompatible avec CUDA moderne)
    warnings =
      lib.optional (cfg.llamaCpp.enable && gpu == "nvidia-legacy" && cfg.llamaCpp.acceleration == "auto")
        "IA-Suite : Le pilote Nvidia Legacy (470) ne prend pas en charge les versions récentes de CUDA. llama.cpp a basculé automatiquement en mode CPU pour préserver la stabilité du système.";

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
        ENABLE_OLLAMA_API = "False";
        OPENAI_API_BASE_URLS =
          let
            llamaUrl = lib.optional cfg.llamaCpp.enable "http://127.0.0.1:${toString cfg.llamaCpp.port}/v1";
            hermesUrl = lib.optional cfg.hermes.enable "http://127.0.0.1:${toString cfg.hermes.apiPort}/v1";
          in
          lib.concatStringsSep ";" (llamaUrl ++ hermesUrl);
        OPENAI_API_KEYS =
          let
            llamaKey = lib.optional cfg.llamaCpp.enable (if cfg.llamaCpp.apiKey != null then cfg.llamaCpp.apiKey else "llama");
            hermesKey = lib.optional cfg.hermes.enable (if cfg.hermes.apiKey != "" then cfg.hermes.apiKey else "hermes");
          in
          lib.concatStringsSep ";" (llamaKey ++ hermesKey);
        ANONYMIZED_TELEMETRY = "False";
        DO_NOT_TRACK = "True";
        SCARF_NO_ANALYTICS = "True";
      };
    };

    # 4. 🤖 Service natif Agent IA Hermes (Nous Research) — systemd user service
    #    Pré-requis : installer Hermes une première fois via :
    #    curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash
    systemd.services.hermes-agent = lib.mkIf cfg.hermes.enable {
      description = "Hermes Agent — Agent IA autonome Nous Research (natif)";
      after = [ "network-online.target" ] ++ lib.optional cfg.llamaCpp.enable "llama-cpp.service";
      wants = [ "network-online.target" ] ++ lib.optional cfg.llamaCpp.enable "llama-cpp.service";
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "simple";
        User = username;
        Group = "users";
        WorkingDirectory = "~";
        ExecStartPre = "${pkgs.bash}/bin/bash -c '${userHome}/.local/bin/hermes gateway stop 2>/dev/null || true'";
        ExecStart = "${userHome}/.local/bin/hermes gateway run --replace";
        Restart = "on-failure";
        RestartSec = 10;
        TimeoutStopSec = 40;
        NoNewPrivileges = true;
        PrivateTmp = true;
      };

      # Bash et coreutils nécessaires dans le PATH (le wrapper hermes utilise #!/usr/bin/env bash)
      path = with pkgs; [
        bash
        coreutils
      ];

      environment = {
        HOME = userHome;
        HERMES_HOME = "${userHome}/.hermes";
        HERMES_WRITE_SAFE_ROOT = "${userHome}/.hermes";
        HERMES_DASHBOARD = "1";
        HERMES_DASHBOARD_PORT = toString cfg.hermes.dashboardPort;
        HERMES_DASHBOARD_BASIC_AUTH_USERNAME = cfg.hermes.dashboardUsername;
        HERMES_DASHBOARD_BASIC_AUTH_PASSWORD = cfg.hermes.dashboardPassword;
        HERMES_DASHBOARD_BASIC_AUTH_SECRET = "chomiamos-hermes-session-secret-key-2026";
        API_SERVER_ENABLED = "true";
        API_SERVER_PORT = toString cfg.hermes.apiPort;
        API_SERVER_KEY = cfg.hermes.apiKey;
        OPENAI_BASE_URL = "http://127.0.0.1:${toString cfg.llamaCpp.port}/v1";
        OPENAI_API_KEY = if cfg.llamaCpp.apiKey != null then cfg.llamaCpp.apiKey else "llama";
      } // lib.optionalAttrs (cfg.hermes.defaultModel != null) {
        HERMES_MODEL = cfg.hermes.defaultModel;
      };
    };

    # 5. 🛡️ Pare-feu réseau déclaratif
    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall (
      lib.optional cfg.llamaCpp.enable cfg.llamaCpp.port
      ++ lib.optional cfg.openWebUI.enable cfg.openWebUI.port
      ++ lib.optionals cfg.hermes.enable [
        cfg.hermes.apiPort
        cfg.hermes.dashboardPort
      ]
    );

    # 6. 🖥️ Outils et raccourcis dans le menu d'applications GNOME / Bureau
    environment.systemPackages = [
      # Outil CLI Hugging Face Hub (expose huggingface-cli et hf dans le PATH sans collision avec Python système)
      (pkgs.python313Packages.toPythonApplication pkgs.python313Packages.huggingface-hub)

      # Outils CLI llama.cpp (llama-cli, llama-quantize, etc.) avec accélération GPU dans le PATH
      (lib.mkIf cfg.llamaCpp.enable llamaPackage)

      (lib.mkIf cfg.llamaCpp.enable (
        pkgs.makeDesktopItem {
          name = "llama-cpp";
          desktopName = "llama.cpp Web UI";
          comment = "Interface Web intégrée et serveur d'inférence llama.cpp";
          exec = "xdg-open http://localhost:${toString cfg.llamaCpp.port}";
          icon = "preferences-system";
          categories = [
            "Development"
            "Utility"
          ];
        }
      ))

      (lib.mkIf cfg.openWebUI.enable (
        pkgs.makeDesktopItem {
          name = "open-webui";
          desktopName = "Open WebUI";
          comment = "Interface Web IA locale (llama.cpp & Hermes)";
          exec = "xdg-open http://localhost:${toString cfg.openWebUI.port}";
          icon = "chat-message-new";
          categories = [
            "Development"
            "Utility"
          ];
        }
      ))

      (lib.mkIf cfg.hermes.enable (
        pkgs.makeDesktopItem {
          name = "hermes-agent";
          desktopName = "Hermes Agent";
          comment = "Tableau de bord de l'agent IA Hermes (Nous Research)";
          exec = "xdg-open http://localhost:${toString cfg.hermes.dashboardPort}";
          icon = "system-run";
          categories = [
            "Development"
            "Utility"
          ];
        }
      ))
    ];

    # 7. 🔌 Autorisation sudo sans mot de passe pour l'agent Hermes via protocole ACP (VS Code, etc.)
    #    Usage direct : hermes acp (binaire natif, plus besoin de podman exec)
    security.sudo.extraRules = lib.mkIf cfg.hermes.enable [
      {
        users = [ username ];
        commands = [
          {
            command = "${userHome}/.local/bin/hermes acp";
            options = [ "NOPASSWD" ];
          }
        ];
      }
    ];
  };
}
