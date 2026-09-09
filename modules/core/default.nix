{ config, pkgs, lib, ... }:

let
  cfg = config.chomiamos;
in
{
  # =========================================================================
  # ⚙️ SOCLE SYSTÈME NIXOS (CORE MODULE)
  # =========================================================================

  imports = [
    ./sysctl-gaming.nix
    ./firewall.nix
    ./browser.nix
    ./users.nix
  ];

  # -------------------------------------------------------------------------
  # 🛠️ CONFIGURATION NIX & PAQUETS UNFREE
  # -------------------------------------------------------------------------
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    accept-flake-config = true;
    substituters = [
      "https://cache.nixos.org"
      "https://cosmic.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "cosmic.cachix.org-1:Dya9IyXD4xdBehWjrkPv6rtxpmACbuUuRJDTOMs8ayE="
    ];
    trusted-users = [
      "root"
      "@wheel"
    ];
    auto-optimise-store = true;
    max-jobs = "auto";
    cores = 0; # Nix ajustera dynamiquement les cœurs sans sature la RAM
  };

  # Inclusion sécurisée du token GitHub s'il existe (évite le rate-limiting nix)
  nix.extraOptions = lib.optionalString (builtins.pathExists ../../secrets/github-token.conf) ''
    !include /etc/nixos/secrets/github-token.conf
  '';

  # Nettoyage et optimisation automatiques hebdomadaires du magasin Nix
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };
  nix.optimise.automatic = true;

  nixpkgs.config.allowUnfree = true;

  # -------------------------------------------------------------------------
  # 🏷️ IDENTITÉ DU SYSTÈME & BRANDING DU BOOTLOADER (GRUB)
  # -------------------------------------------------------------------------
  system.nixos.distroName = "ChomiamOS";
  system.nixos.distroId = "chomiamos";

  # -------------------------------------------------------------------------
  # 🚀 DEMARRAGE & BOOTLOADER
  # -------------------------------------------------------------------------
  boot = {
    kernelParams = [
      "quiet"
      "splash"
    ];

    plymouth.enable = true;

    loader = {
      timeout = 3;
      grub = {
        enable = true;
        device = "nodev";
        efiSupport = true;
      };
      efi.canTouchEfiVariables = true;
    };
  };

  # -------------------------------------------------------------------------
  # 🌐 RÉSEAU, NOM D'HÔTE & LOCALISATION
  # -------------------------------------------------------------------------
  networking = {
    hostName = cfg.hostName;
    networkmanager = {
      enable = true;
      settings = {
        connection = {
          "wifi.powersave" = 2; # Performances max Wi-Fi
        };
      };
    };

    nameservers = [
      "1.1.1.1"
      "9.9.9.9"
    ];
  };

  services.resolved.enable = true;
  time.timeZone = cfg.timeZone;
  console.keyMap = "fr";

  i18n = {
    defaultLocale = cfg.defaultLocale;
    extraLocaleSettings = {
      LC_ADDRESS = cfg.defaultLocale;
      LC_IDENTIFICATION = cfg.defaultLocale;
      LC_MEASUREMENT = cfg.defaultLocale;
      LC_MONETARY = cfg.defaultLocale;
      LC_NAME = cfg.defaultLocale;
      LC_NUMERIC = cfg.defaultLocale;
      LC_PAPER = cfg.defaultLocale;
      LC_TELEPHONE = cfg.defaultLocale;
      LC_TIME = cfg.defaultLocale;
    };
  };

  services.xserver.xkb = {
    layout = "fr";
    variant = "";
  };

  # -------------------------------------------------------------------------
  # 🔊 AUDIO, IMPRESSION & MATÉRIEL
  # -------------------------------------------------------------------------
  services.printing.enable = true;
  hardware.enableAllFirmware = true;
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Version du système
  system.stateVersion = cfg.stateVersion;
}
