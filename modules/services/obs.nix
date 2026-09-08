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
      package = pkgs.obs-studio;
      plugins = with pkgs.obs-studio-plugins; [
        wlrobs
        obs-backgroundremoval
        obs-pipewire-audio-capture
        obs-gstreamer
        obs-vkcapture
      ];
    };
  };
}
