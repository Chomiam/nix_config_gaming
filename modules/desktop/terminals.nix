{ config, lib, pkgs, ... }:

let
  selectedTerminal = config.chomiamos.terminal;
in
{
  # =========================================================================
  # 💻 GESTION EXCLUSIVE DE L'ÉMULATEUR DE TERMINAL
  # Seul le terminal sélectionné dans le Dashboard ChomiamOS est conservé.
  # Tous les autres terminaux (COSMIC Term, GNOME Terminal, Konsole, Xterm...)
  # sont systématiquement exclus du système et des environnements de bureau.
  # =========================================================================

  # 1. Exclusion universelle de Xterm (serveur d'affichage X11 / Display Managers)
  services.xserver.excludePackages = [ pkgs.xterm ];

  # 2. COSMIC Desktop : exclusion de cosmic-term si non sélectionné
  environment.cosmic.excludePackages = lib.optionals (selectedTerminal != "cosmic-term") (with pkgs; [
    cosmic-term
  ]);

  # 3. GNOME Desktop : exclusion de gnome-terminal & gnome-console si non sélectionnés
  environment.gnome.excludePackages = lib.optionals (selectedTerminal != "gnome-terminal") (with pkgs; [
    gnome-terminal
    gnome-console
  ]);
  programs.gnome-terminal.enable = lib.mkIf (selectedTerminal != "gnome-terminal") (lib.mkForce false);

  # 4. Cinnamon Desktop : exclusion de gnome-terminal si non sélectionné
  environment.cinnamon.excludePackages = lib.optionals (selectedTerminal != "gnome-terminal") (with pkgs; [
    gnome-terminal
  ]);

  # 5. KDE Plasma 6 : exclusion de Konsole si non sélectionné
  environment.plasma6.excludePackages = lib.optionals (selectedTerminal != "konsole") (with pkgs.kdePackages; [
    konsole
  ]);
}
