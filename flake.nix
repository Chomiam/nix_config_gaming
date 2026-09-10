{
  description = "Configuration NixOS Modulaire pour Gaming, Matériel (AMD/NVIDIA/Intel) et Home Manager";

  nixConfig = {
    extra-substituters = [
      "https://duckstation.cachix.org"
      "https://chomiamos-dashboard.cachix.org"
    ];
    extra-trusted-public-keys = [
      "duckstation.cachix.org-1:tNC6UMoM5ZojxBRDdPNHC3xBlk7hnClCtsGsho3YiY4="
      "chomiamos-dashboard.cachix.org-1:DrjJpGp7tzIMJo6s4dQdwWDopszgo1EFkm34PEN+D+w="
    ];
  };

  # ===========================================================================
  # 📦 INPUTS (SOURCES DES PAQUETS ET MODULES)
  # ===========================================================================
  inputs = {
    # Nixpkgs branche stable 26.05
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";

    # Support Déclaratif Flatpak
    nix-flatpak.url = "github:gmodena/nix-flatpak";

    # Thème Catppuccin
    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Home Manager (Gestion de l'environnement utilisateur)
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Nixpkgs branche unstable (fournit COSMIC Desktop 1.5+ officiel)
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    # Dépôt d'applets communautaires pour COSMIC Desktop
    ext-cosmic-applets = {
      url = "github:wingej0/ext-cosmic-applets-flake";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # Jovian-NixOS (Fournit le module et le paquet Decky Loader pour Steam)
    jovian = {
      url = "github:Jovian-Experiments/Jovian-NixOS";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # ChomiamOS Dashboard (Tableau de bord système officiel en Rust / Tauri v2 / xterm.js)
    chomiamos-dashboard = {
      url = "github:Chomiam/chomiamos-dashboard";
    };

    # Émulateur PlayStation 1 DuckStation (compilé depuis les sources avec cache Cachix)
    duckstation = {
      url = "github:Chomiam/duckstation-nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  # ===========================================================================
  # ⚙️ OUTPUTS (ASSEMBLAGE MODULAIRE DE LA CONFIGURATION NIXOS)
  # ===========================================================================
  outputs = { self, nixpkgs, ... }@inputs:
    let
      # Fusion récursive : vars-defaults.nix (schéma de référence) + vars.nix (personnalisations utilisateur)
      # Les nouvelles variables ajoutées dans vars-defaults.nix sont automatiquement disponibles
      # chez tous les utilisateurs, même si leur vars.nix ne les contient pas encore.
      defaults = import ./vars-defaults.nix;
      userVars = import ./vars.nix;
      vars = let
        recursiveMerge = base: override:
          builtins.mapAttrs (name: baseValue:
            if override ? ${name} then
              if builtins.isAttrs baseValue && builtins.isAttrs override.${name}
              then recursiveMerge baseValue override.${name}
              else override.${name}
            else baseValue
          ) base // (builtins.removeAttrs override (builtins.attrNames base));
      in recursiveMerge defaults userVars;

      desktopSystem = nixpkgs.lib.nixosSystem {
        # Transmet 'inputs' et 'vars' à tous les modules NixOS
        specialArgs = { inherit inputs vars; };

        modules = [
          # 🖥️ Architecture système
          { nixpkgs.hostPlatform = "x86_64-linux"; }

          # 🛠️ Configuration de l'hôte principal (Desktop)
          ./hosts/desktop/configuration.nix

          # 📦 Insertion des modules système tiers
          inputs.nix-flatpak.nixosModules.nix-flatpak
          inputs.home-manager.nixosModules.home-manager

          # 🏠 Configuration dynamique de Home Manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = "backup";

              # Transmet 'inputs' et 'vars' à tous les modules Home-Manager
              extraSpecialArgs = { inherit inputs vars; };

              # 🛠️ Modules partagés Home Manager
              sharedModules = [
                inputs.catppuccin.homeModules.catppuccin
              ];

              # 👤 Chargement dynamique du profil utilisateur principal
              users.${vars.user.username} = import ./home;
            };
          }
        ];
      };
    in
    {
      # 📦 Export du module Chomiamos pour réutilisation externe / partage
      nixosModules = {
        default = ./modules;
        chomiamos = ./modules;
      };

      nixosConfigurations = {
        ${vars.hostName} = desktopSystem;
        default = desktopSystem;
        nixos = desktopSystem;
      } // {
        chomiamos = desktopSystem;
      };
    };
}
