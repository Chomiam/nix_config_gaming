{ config, lib, pkgs, inputs, ... }:

let
  pkgs-unstable = inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system};
  customPackagesPath = ../../custom-packages.nix;
  userCustom = if builtins.pathExists customPackagesPath
               then import customPackagesPath
               else { stable = []; unstable = []; };

  # Résolution sécurisée des paquets déclarés par l'utilisateur
  # Ignore silencieusement tout attribut inexistant pour ne jamais bloquer la reconstruction de l'OS
  validStable = builtins.filter (name: pkgs ? ${name}) (userCustom.stable or []);
  validUnstable = builtins.filter (name: pkgs-unstable ? ${name}) (userCustom.unstable or []);
in
{
  # =========================================================================
  # 📦 MODULE CHOMIAMOS : PAQUETS NIX PERSONNALISÉS (STABLE & UNSTABLE)
  # =========================================================================

  environment.systemPackages =
    (map (name: pkgs.${name}) validStable) ++
    (map (name: pkgs-unstable.${name}) validUnstable);
}
