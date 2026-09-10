{ config, lib, pkgs, ... }:

let
  cfg = config.chomiamos.services.obs;
in
{
  # =========================================================================
  # 📹 OBS STUDIO & PLUGINS STREAMING / CAPTURE
  # =========================================================================

  config = lib.mkIf cfg.enable {
    programs.obs-studio = {
      enable = true;
      enableVirtualCamera = true;
      package = pkgs.obs-studio;
      plugins = with pkgs.obs-studio-plugins; [
        wlrobs
        obs-backgroundremoval
        obs-pipewire-audio-capture
        obs-gstreamer
        obs-vkcapture
        obs-vaapi
        obs-composite-blur
        obs-source-record
        obs-source-clone
        obs-move-transition
        waveform
        input-overlay
        advanced-scene-switcher
      ];
    };

    # Outils pour la capture de jeux Vulkan/OpenGL (obs-gamecapture)
    environment.systemPackages = [
      pkgs.obs-studio-plugins.obs-vkcapture
    ];
  };
}

