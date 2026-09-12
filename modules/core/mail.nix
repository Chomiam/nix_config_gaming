{ config, pkgs, lib, ... }:

let
  selected = config.chomiamos.mailClient or "thunderbird";

  pkg =
    if selected == "thunderbird" then pkgs.thunderbird
    else if selected == "mailspring" then pkgs.mailspring
    else null;
in
{
  # =========================================================================
  # 📧 GESTIONNAIRE DU CLIENT DE MESSAGERIE E-MAIL (THUNDERBIRD / MAILSPRING)
  # =========================================================================

  users.users."${config.chomiamos.user.username}".packages = lib.optionals (pkg != null) [ pkg ];
}
