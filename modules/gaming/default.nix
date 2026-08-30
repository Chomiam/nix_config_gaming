{ pkgs, vars, inputs, ... }:

let
  pkgs-unstable = inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in
{
  # =========================================================================
  # 🕹️ SUITE GAMING & COMPATIBILITÉ WINDOWS
  # =========================================================================

  # Support du matériel Steam (Manettes, Steam Deck / Controller, etc.)
  hardware.steam-hardware.enable = true;

  # Client Steam principal
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    gamescopeSession.enable = true;
  };

  # Feral GameMode (Optimisation priorités CPU/GPU lors des jeux)
  programs.gamemode = {
    enable = true;
    enableRenice = true;
    settings.general = {
      renice = 10;
      enableWsi = true;
    };
  };

  # GameScope (Micro-compositeur Wayland isolateur de résolution/HDR/FSR)
  programs.gamescope = {
    enable = true;
    capSysNice = false;
  };

  # Outils & Launchers de jeu système
  environment.systemPackages = with pkgs; [
    umu-launcher
    wine64
    winetricks
    protontricks
    steam-run
  ];

  # Paquets utilisateur gaming pour l'utilisateur principal
  users.users."${vars.user.username}".packages = with pkgs; [
    lutris
    heroic
    eden
    ludusavi
    protonup-qt
    pkgs-unstable.mangohud
    pkgs-unstable.goverlay
  ];
}
