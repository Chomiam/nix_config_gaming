{ config, pkgs, lib, ... }:

let
  cfg = config.chomiamos.services.flatpak;
  gamingCfg = config.chomiamos.gaming;
  username = config.chomiamos.user.username;
in
{
  # =========================================================================
  # 📦 SUPPORT FLATPAK (NIX-FLATPAK)
  # =========================================================================

  config = lib.mkIf cfg.enable {
    services.flatpak = {
      enable = true;
      update.auto.enable = true;
      update.onActivation = true;

      remotes = lib.mkOptionDefault (
        [
          {
            name = "flathub";
            location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
          }
        ]
        ++ lib.optionals gamingCfg.geforceNow [
          {
            name = "GeForceNOW";
            location = "https://international.download.nvidia.com/GFNLinux/flatpak/geforcenow.flatpakrepo";
          }
        ]
      );

      packages = [
        "org.signal.Signal"
        "rocks.shy.VacuumTube"
        "it.mijorus.gearlever"
      ] ++ lib.optional (gamingCfg.sober) "org.vinegarhq.Sober"
      ++ lib.optional (config.chomiamos.services.flatseal.enable) "com.github.tchx84.Flatseal"
      ++ lib.optional (config.chomiamos.services.slicers.orcaslicer.enable) "com.orcaslicer.OrcaSlicer"
      ++ lib.optional (config.chomiamos.services.slicers.prusaslicer.enable) "com.prusa3d.PrusaSlicer"
      ++ lib.optional (config.chomiamos.services.slicers.cura.enable) "com.ultimaker.cura"
      ++ lib.optional (config.chomiamos.services.slicers.bambustudio.enable) "com.bambulab.BambuStudio"
      ++ lib.optionals gamingCfg.geforceNow [
        {
          appId = "com.nvidia.geforcenow";
          origin = "GeForceNOW";
        }
      ]
      ++ lib.optional (config.chomiamos.discordClient == "equibop") "io.github.equicord.equibop"
      ++ lib.optional (config.chomiamos.discordClient == "vesktop") "dev.vencord.Vesktop";
    };


    # 📌 Override du fichier .desktop de GeForce NOW avec StartupWMClass
    # Permet à GNOME et COSMIC d'associer la fenêtre ouverte (WMClass: GeForceNOW) au raccourci du dock
    home-manager.users."${username}" = {
      xdg.desktopEntries."com.nvidia.geforcenow" = lib.mkIf gamingCfg.geforceNow {
        name = "NVIDIA GeForce NOW";
        genericName = "NVIDIA GeForce NOW";
        exec = "flatpak run --branch=master --arch=x86_64 --command=GeForceNOW com.nvidia.geforcenow";
        icon = "com.nvidia.geforcenow";
        categories = [ "Network" "Game" ];
        settings = {
          StartupWMClass = "GeForceNOW";
          X-Flatpak = "com.nvidia.geforcenow";
        };
      };
    };
  };
}
