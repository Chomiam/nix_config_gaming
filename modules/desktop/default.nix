{ ... }:

{
  # =========================================================================
  # 🖥️ SECTEUR DESKTOP : ENVIRONNEMENTS GRAPHIQUES
  # Importation inconditionnelle : chaque environnement s'active selon
  # config.chomiamos.desktop.env ("gnome" | "cosmic" | "both" | "none")
  # =========================================================================
  imports = [
    ./gnome.nix
    ./cosmic.nix
    ./cinnamon.nix
    ./kde.nix
    ./budgie.nix
    ./setup.nix
    ./wallpapers.nix
  ];
}
