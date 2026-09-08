{ config, lib, pkgs, ... }:

{
  # =========================================================================
  # 🟢 PROFIL GPU : NVIDIA MODERNE (GTX 1650, RTX 20xx / 30xx / 40xx et +)
  # =========================================================================

  config = lib.mkIf (config.chomiamos.hardware.gpu == "nvidia") {
    # Utilise le noyau XanMod STABLE (et non latest) pour garantir la compatibilité du module NVIDIA out-of-tree
    boot.kernelPackages = pkgs.linuxPackages_xanmod;

    # Active le pilote propriétaire NVIDIA pour X11 / Wayland
    services.xserver.videoDrivers = [ "nvidia" ];

    hardware.nvidia = {
      # Modesetting est requis pour Wayland et la plupart des compositeurs modernes
      modesetting.enable = true;

      # Gestion de l'alimentation (peut causer des problèmes sur certains GPU si activé sans besoin)
      powerManagement.enable = false;
      powerManagement.finegrained = false;

      # Utilise le pilote propriétaire fermé pour une stabilité maximale sur les jeux
      open = false;

      # Active l'outil nvidia-settings
      nvidiaSettings = true;

      # Utilise la branche stable des pilotes NVIDIA
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };

    # Graphiques 32-bit (Steam) et accélération matérielle
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        vkbasalt
        libva
      ];
    };
  };
}
