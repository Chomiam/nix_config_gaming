{ vars, ... }:

let
  isKde = vars.desktopEnv == "kde";
  configuredTerminal = vars.terminal or "kitty";
in
{
  # =========================================================================
  # 🎨 THÈME GLOBAL CATPPUCCIN (MOCHA / LAVENDER)
  # =========================================================================

  catppuccin = {
    enable = true;
    autoEnable = true;
    flavor = "mocha";
    accent = "lavender";

    kitty.enable = (configuredTerminal == "kitty");
    alacritty.enable = (configuredTerminal == "alacritty");
    # Sous KDE, on laisse Plasma gérer librement le style d'application (Breeze, Kvantum, etc.)
    kvantum.enable = !isKde;
  };
}
