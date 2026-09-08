{ config, ... }:

let
  username = config.chomiamos.user.username;
in
{
  # =========================================================================
  # 💾 MONTAGE DISQUE DE JEUX (/mnt/Games)
  # =========================================================================

  # Permission dynamique pour le dossier de jeux attribué à l'utilisateur principal
  systemd.tmpfiles.rules = [
    "z /mnt/Games 0775 ${username} users -"
  ];

  # Configuration du montage BTRFS avec compression ZSTD
  fileSystems."/mnt/Games" = {
    device = "/dev/disk/by-uuid/5e42df83-3aff-45c8-a8e6-b25e07ba0130";
    fsType = "btrfs";
    options = [
      "defaults"
      "nofail"
      "compress=zstd"
    ];
  };

  systemd.services.systemd-tmpfiles-setup.after = [ "mnt-Games.mount" ];
}
