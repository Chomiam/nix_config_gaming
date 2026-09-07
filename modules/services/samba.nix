{ pkgs, vars, ... }:

{
  # =========================================================================
  # 📂 PARTAGE DE FICHIERS RÉSEAU SAMBA (SMB / CIFS)
  # =========================================================================

  services.samba = {
    enable = true;
    openFirewall = true;

    settings = {
      global = {
        "workgroup" = "WORKGROUP";
        "server string" = "${vars.hostName} Samba Server";
        "netbios name" = vars.hostName;
        "security" = "user";

        # Permet l'accès invité sans exiger de compte/mot de passe Samba
        "map to guest" = "Bad User";

        # Compatibilité SMB (SMB2 supporté nativement dès Windows 7)
        "min protocol" = "SMB2";
        "ea support" = "yes";
      };

      # Partage direct du dossier personnel (/home/chomiam)
      "${vars.user.username}" = {
        "path" = vars.user.homeDirectory;
        "browseable" = "yes";
        "read only" = "no";
        "guest ok" = "yes";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = vars.user.username;
        "comment" = "Dossier personnel de ${vars.user.username}";
      };

      # Partage de la racine /home
      "home" = {
        "path" = "/home";
        "browseable" = "yes";
        "read only" = "no";
        "guest ok" = "yes";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = vars.user.username;
        "comment" = "Repertoire racine /home";
      };
    };
  };

  # Découverte automatique du partage sur le réseau Windows (WSDD / NetBIOS)
  services.samba-wsdd = {
    enable = true;
    openFirewall = true;
  };
}
