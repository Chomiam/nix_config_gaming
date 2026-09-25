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

    # 📜 Exposition déclarative du prompt système global pour les scripts, agents et outils locaux
    environment.etc."ollama/system-prompt.txt" = lib.mkIf (cfg.systemPrompt != null && cfg.systemPrompt != "") {
      text = cfg.systemPrompt;
      mode = "0644";
    };

    environment.sessionVariables = lib.mkIf (cfg.systemPrompt != null && cfg.systemPrompt != "") {
      OLLAMA_SYSTEM_PROMPT = cfg.systemPrompt;
    };

    # =========================================================================
    # 🤖 CLIENT CLI IA AICHAT (PRÉCONFIGURÉ AVEC OLLAMA LOCAL)
    # =========================================================================
    environment.systemPackages = lib.mkIf cfg.aichat [
      pkgs.aichat
    ];

    # Configuration système déclarative d'AIChat connectée à Ollama
    environment.etc."aichat/config.yaml" = lib.mkIf cfg.aichat {
      text = ''
        # Configuration automatique ChomiamOS pour AIChat
        model: ollama:${if (cfg.model != null && cfg.model != "") then cfg.model else "qwen2.5-coder:7b"}
        stream: true
        highlight: true
        keybindings: emacs

        clients:
          - type: openai-compatible
            name: ollama
            api_base: http://localhost:${toString cfg.port}/v1
      '';
      mode = "0644";
    };

    # Intégration interactive Bash
    programs.bash.interactiveShellInit = lib.mkIf cfg.aichat ''
      # AIChat : Détection automatique de la configuration Ollama si non définie
      if [ -z "$AICHAT_CONFIG_FILE" ] && [ ! -f "$HOME/.config/aichat/config.yaml" ] && [ -f /etc/aichat/config.yaml ]; then
        export AICHAT_CONFIG_FILE=/etc/aichat/config.yaml
      fi
      alias ai="aichat"

      # Raccourci Alt+e : Génération de commande shell intelligente à partir de la saisie
      _aichat_bash() {
        if [[ -n "$READLINE_LINE" ]]; then
          READLINE_LINE=$(aichat -e "$READLINE_LINE")
          READLINE_POINT=''${#READLINE_LINE}
        fi
      }
      bind -x '"\ee": _aichat_bash'
    '';

    # Intégration interactive Zsh
    programs.zsh.interactiveShellInit = lib.mkIf cfg.aichat ''
      # AIChat : Détection automatique de la configuration Ollama si non définie
      if [[ -z "$AICHAT_CONFIG_FILE" ]] && [[ ! -f "$HOME/.config/aichat/config.yaml" ]] && [[ -f /etc/aichat/config.yaml ]]; then
        export AICHAT_CONFIG_FILE=/etc/aichat/config.yaml
      fi
      alias ai="aichat"

      # Raccourci Alt+e : Génération de commande shell intelligente
      _aichat_zsh() {
        if [[ -n "$BUFFER" ]]; then
          local _old=$BUFFER
          BUFFER+="⌛"
          zle -I && zle redisplay
          BUFFER=$(aichat -e "$_old")
          zle end-of-line
        fi
      }
      zle -N _aichat_zsh
      bindkey '\ee' _aichat_zsh
    '';

    # Intégration interactive Fish
    programs.fish.interactiveShellInit = lib.mkIf cfg.aichat ''
      # AIChat : Détection automatique de la configuration Ollama si non définie
      if not set -q AICHAT_CONFIG_FILE; and not test -f "$HOME/.config/aichat/config.yaml"; and test -f /etc/aichat/config.yaml
        set -gx AICHAT_CONFIG_FILE /etc/aichat/config.yaml
      end
      alias ai="aichat"

      # Raccourci Alt+e : Génération de commande shell intelligente
      function _aichat_fish
        set -l _old (commandline)
        if test -n "$_old"
          echo -n "⌛"
          commandline -f repaint
          commandline (aichat -e "$_old")
        end
      end
      bind \ee _aichat_fish
    '';
  };
}
