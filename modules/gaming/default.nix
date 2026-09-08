{ config, lib, pkgs, inputs, ... }:

let
  cfg = config.chomiamos;
  pkgs-unstable = inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in
{
  imports = [
    ./decky-loader.nix
  ];

  # =========================================================================
  # 🕹️ SUITE GAMING & COMPATIBILITÉ WINDOWS
  # =========================================================================

  config = lib.mkIf cfg.gaming.enable {
    # Support du matériel Steam (Manettes, Steam Deck / Controller, etc.)
    hardware.steam-hardware.enable = cfg.gaming.launchers.steam;

    # Client Steam principal
    programs.steam = lib.mkIf cfg.gaming.launchers.steam {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      gamescopeSession.enable = true;
      extraPackages = with pkgs; [
        pkgs-unstable.mangohud
      ];
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

    # Sunshine (Serveur d'auto-hébergement et streaming de jeux vers Moonlight)
    services.sunshine = {
      enable = true;
      autoStart = true;
      capSysAdmin = true;
      openFirewall = true;
    };

    # Outils & Launchers de jeu système
    environment.systemPackages = with pkgs; [
      umu-launcher
      wineWow64Packages.stable
      winetricks
      protontricks
      steam-run
    ];

    # Paquets utilisateur gaming pour l'utilisateur principal
    users.users."${cfg.user.username}".packages = with pkgs; [
      eden
      ludusavi
      pkgs-unstable.protonplus
      pkgs-unstable.mangohud
      pkgs-unstable.goverlay
    ]
    ++ lib.optional cfg.gaming.launchers.lutris lutris
    ++ lib.optional cfg.gaming.launchers.heroic (heroic.override {
      extraPkgs = pkgs: with pkgs; [
        gamemode
        mangohud
        gamescope
      ];
    })
    ++ lib.optional cfg.gaming.launchers.faugus pkgs-unstable.faugus-launcher;
  };
}
