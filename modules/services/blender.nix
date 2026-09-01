{ pkgs, lib, vars, inputs, ... }:

let
  pkgs-unstable = inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system};
  enable = vars.blender or false;
in
{
  # =========================================================================
  # 🎨 BLENDER (SUITE DE MODÉLISATION & ANIMATION 3D - NIXPKGS UNSTABLE)
  # =========================================================================

  config = lib.mkIf enable {
    users.users."${vars.user.username}".packages = [
      pkgs-unstable.blender
    ];
  };
}
