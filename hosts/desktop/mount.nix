{ config, pkgs, lib, ... }:

let
  username = config.chomiamos.user.username;
in
{
  # =========================================================================
  # 💾 MONTAGES DE DISQUES PERSISTANTS (GÉRÉS PAR CHOMIAMOS DASHBOARD)
  # Ce fichier est préservé automatiquement lors des synchronisations GitHub.
  # =========================================================================

  systemd.tmpfiles.rules = [
    "d /mnt/Emudeck 0775 ${username} users -"
    "z /mnt/Emudeck 0775 ${username} users -"
  ];

  fileSystems."/mnt/Emudeck" = {
    device = "/dev/disk/by-uuid/5e42df83-3aff-45c8-a8e6-b25e07ba0130";
    fsType = "btrfs";
    options = [
      "defaults"
      "nofail"
      "compress=zstd"
    ];
  };

  systemd.services.systemd-tmpfiles-setup.after = [ "local-fs.target" ];
}
