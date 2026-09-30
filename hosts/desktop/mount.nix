{ config, pkgs, lib, ... }:

let
  username = config.chomiamos.user.username;
in
{
  # =========================================================================
  # 💾 MONTAGES DE DISQUES PERSISTANTS (GÉRÉS PAR CHOMIAMOS DASHBOARD)
  # Ce fichier est préservé automatiquement lors des synchronisations GitHub.
  # Les disques configurés dans le Dashboard sont enregistrés ici localement.
  # =========================================================================

  systemd.tmpfiles.rules = [
    "d /mnt 0775 root users -"
    "z /mnt 0775 root users -"
    "d /media 0775 root users -"
    "z /media 0775 root users -"
  ];

  systemd.services.systemd-tmpfiles-setup.after = [ "local-fs.target" ];
}
