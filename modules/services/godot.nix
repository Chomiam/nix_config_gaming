{ pkgs, lib, vars, ... }:

let
  enable = vars.godot or false;
in
{
  # =========================================================================
  # 🎮 GODOT ENGINE (MOTEUR DE JEU 2D/3D)
  # =========================================================================

  config = lib.mkIf enable {
    users.users."${vars.user.username}".packages = with pkgs; [
      godot
    ];
  };
}
