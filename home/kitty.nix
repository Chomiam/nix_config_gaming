{ pkgs, ... }:

{
  # =========================================================================
  # 💻 TERMINAL PRINCIPAL (KITTY)
  # =========================================================================

  programs.kitty = {
    enable = true;

    settings = {
      window_padding_width = 8;
      background_opacity = "0.90";

      font_family = "JetBrainsMono Nerd Font";
      font_size = 11;

      cursor_shape = "block";
      cursor_blink_interval = "0.5";
      confirm_os_window_close = 0;
    };
  };

  # Raccourci application par défaut pour GNOME / Dconf
  dconf.settings = {
    "org/gnome/desktop/default-applications/terminal" = {
      exec = "kitty";
      exec-arg = "-e";
    };
  };
}
