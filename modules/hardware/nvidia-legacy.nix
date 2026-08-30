{ config, pkgs, ... }:

{
  # =========================================================================
  # 🟢 PROFIL GPU : NVIDIA ANCIENNE GÉNÉRATION (< GTX 1650 : GTX 10xx, 9xx, 7xx, etc.)
  # =========================================================================

  # Utilise le noyau XanMod STABLE pour éviter la casse du module out-of-tree legacy
  boot.kernelPackages = pkgs.linuxPackages_xanmod;

  # Active le pilote NVIDIA
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    open = false;
    nvidiaSettings = true;

    # Pilote legacy 470 (support des cartes antérieures à l'architecture Turing/GTX 1650)
    package = config.boot.kernelPackages.nvidiaPackages.legacy_470;
  };

  # Support Graphique 32-bit & Vulkan
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      vkbasalt
      libva
    ];
  };
}
