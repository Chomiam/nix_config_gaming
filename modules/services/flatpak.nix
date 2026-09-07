{ pkgs, lib, vars, ... }:

{
  # =========================================================================
  # 📦 SUPPORT FLATPAK (NIX-FLATPAK)
  # =========================================================================

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
      ++ lib.optionals (vars.gaming.geforceNow or true) [
        {
          name = "GeForceNOW";
          location = "https://international.download.nvidia.com/GFNLinux/flatpak/geforcenow.flatpakrepo";
        }
      ]
    );

    packages = [
      "org.signal.Signal"
      "com.github.tchx84.Flatseal"
      "rocks.shy.VacuumTube"
      "it.mijorus.gearlever"
      "org.vinegarhq.Sober"
    ] ++ lib.optionals (vars.gaming.geforceNow or true) [
      {
        appId = "com.nvidia.geforcenow";
        origin = "GeForceNOW";
      }
    ];
  };

  # 📌 Override du fichier .desktop de GeForce NOW avec StartupWMClass
  # Permet à GNOME et COSMIC d'associer la fenêtre ouverte (WMClass: GeForceNOW) au raccourci du dock
  home-manager.users."${vars.user.username}" = {
    xdg.desktopEntries."com.nvidia.geforcenow" = lib.mkIf (vars.gaming.geforceNow or true) {
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
}
