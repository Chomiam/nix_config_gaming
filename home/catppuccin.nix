{ vars, ... }:

let
  isKde = vars.desktopEnv == "kde";
in
{
  # =========================================================================
  # 🎨 THÈME GLOBALE CATPPUCCIN (MOCHA / LAVENDER)
  # =========================================================================

  catppuccin = {
    enable = true;
    autoEnable = true;
    flavor = "mocha";
    accent = "lavender";

    kitty.enable = true;
    # Sous KDE, on laisse Plasma gérer librement le style d'application (Breeze, Kvantum, etc.)
    kvantum.enable = !isKde;
  };
}
