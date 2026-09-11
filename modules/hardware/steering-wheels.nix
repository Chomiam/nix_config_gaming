{ config, pkgs, lib, ... }:

let
  cfg = config.chomiamos.hardware.steeringWheels.enable;
  username = config.chomiamos.user.username;
in
{
  # =========================================================================
  # 🏎️ SUPPORT DES VOLANTS DE COURSE & SIMRACING (LOGITECH, THRUSTMASTER, FANATEC, PIDFF)
  # =========================================================================

  config = lib.mkIf cfg {

    # 1. 📦 Extra modules noyau pour retour de force (Force Feedback)
    # Les modules sont chargés automatiquement par Udev à l'insertion du volant
    boot.extraModulePackages = with config.boot.kernelPackages; [
      new-lg4ff       # Logitech (G25, G27, G29, G920, Driving Force GT...)
      hid-fanatecff   # Fanatec (CSL, ClubSport, Podium...)
      hid-tmff2       # Thrustmaster (T150, T300RS, T248, T500RS, TS-PC...)
      hid-t150        # Thrustmaster T150 spécifique
      universal-pidff # Universal PID Force Feedback
    ];

    # 2. 🔌 Règles Udev pour autoriser l'accès aux volants & Oversteer sans root
    services.udev.packages = [
      pkgs.oversteer
    ];

    # 3. 🎮 Application GUI Oversteer pour la gestion des volants (rotation, force, profils)
    users.users."${username}".packages = with pkgs; [
      oversteer
    ];
  };
}
