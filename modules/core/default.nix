{ config, pkgs, lib, vars, ... }:

{
  # =========================================================================
  # ⚙️ SOCLE SYSTÈME NIXOS (CORE MODULE)
  # =========================================================================

  imports = [
    ./sysctl-gaming.nix
    ./firewall.nix
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

  # Inclusion sécurisée du token GitHub (évite le rate-limiting nix)
  nix.extraOptions = ''
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
    hostName = vars.hostName;
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
  time.timeZone = vars.timeZone;
  console.keyMap = "fr";

  i18n = {
    defaultLocale = vars.defaultLocale;
    extraLocaleSettings = {
      LC_ADDRESS = vars.defaultLocale;
      LC_IDENTIFICATION = vars.defaultLocale;
      LC_MEASUREMENT = vars.defaultLocale;
      LC_MONETARY = vars.defaultLocale;
      LC_NAME = vars.defaultLocale;
      LC_NUMERIC = vars.defaultLocale;
      LC_PAPER = vars.defaultLocale;
      LC_TELEPHONE = vars.defaultLocale;
      LC_TIME = vars.defaultLocale;
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
  system.stateVersion = vars.stateVersion;
}
