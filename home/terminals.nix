{ vars, ... }:

let
  configuredTerminal = vars.terminal or "kitty";
  gnomeProfileUuid = "95894cfd-82f7-430d-af6e-84d168bc34f5";
in
{
  # =========================================================================
  # 💻 CONFIGURATION DES ÉMULATEURS DE TERMINAUX & THÈME CATPPUCCIN MOCHA
  # =========================================================================

  # 1. KITTY (Accéléré par GPU OpenGL, protocole Kitty Graphics natif)
  # Le thème Catppuccin Mocha est appliqué via catppuccin.kitty.enable = true (catppuccin.nix)
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

  # 2. ALACRITTY (Rust GPU ultra-rapide)
  # Le thème Catppuccin Mocha est appliqué via catppuccin.alacritty.enable = true (catppuccin.nix)
  programs.alacritty = {
    enable = true;

    settings = {
      window = {
        padding = {
          x = 8;
          y = 8;
        };
        opacity = 0.90;
      };

      font = {
        normal = {
          family = "JetBrainsMono Nerd Font";
          style = "Regular";
        };
        size = 11.0;
      };

      cursor = {
        style = {
          shape = "Block";
          blinking = "On";
        };
      };
    };
  };

  # 3. KONSOLE (Terminal KDE Plasma, Sixel & Chafa)
  # Palette Catppuccin Mocha officielle et profil par défaut configuré
  xdg.dataFile."konsole/catppuccin-mocha.colorscheme".text = ''
    [Background]
    Color=30,30,46

    [BackgroundFaint]
    Color=30,30,46

    [BackgroundIntense]
    Color=30,30,46

    [Color0]
    Color=108,112,134

    [Color0Faint]
    Color=108,112,134

    [Color0Intense]
    Color=108,112,134

    [Color1]
    Color=243,139,168

    [Color1Faint]
    Color=243,139,168

    [Color1Intense]
    Color=243,139,168

    [Color2]
    Color=166,227,161

    [Color2Faint]
    Color=166,227,161

    [Color2Intense]
    Color=166,227,161

    [Color3]
    Color=249,226,175

    [Color3Faint]
    Color=249,226,175

    [Color3Intense]
    Color=249,226,175

    [Color4]
    Color=137,180,250

    [Color4Faint]
    Color=137,180,250

    [Color4Intense]
    Color=137,180,250

    [Color5]
    Color=203,166,247

    [Color5Faint]
    Color=203,166,247

    [Color5Intense]
    Color=203,166,247

    [Color6]
    Color=137,220,235

    [Color6Faint]
    Color=137,220,235

    [Color6Intense]
    Color=137,220,235

    [Color7]
    Color=205,214,244

    [Color7Faint]
    Color=205,214,244

    [Color7Intense]
    Color=205,214,244

    [Foreground]
    Color=205,214,244

    [ForegroundFaint]
    Color=205,214,244

    [ForegroundIntense]
    Color=205,214,244

    [General]
    Blur=false
    ColorRandomization=false
    Description=Catppuccin Mocha
    Opacity=0.9
    Wallpaper=
  '';

  xdg.dataFile."konsole/Catppuccin-Mocha.profile".text = ''
    [Appearance]
    ColorScheme=catppuccin-mocha
    Font=JetBrainsMono Nerd Font,11,-1,5,50,0,0,0,0,0

    [General]
    Name=Catppuccin Mocha
    Parent=FALLBACK/
  '';

  xdg.configFile."konsolerc".text = ''
    [Desktop Entry]
    DefaultProfile=Catppuccin-Mocha.profile

    [General]
    ConfigVersion=1

    [UiSettings]
    ColorScheme=catppuccin-mocha
  '';

  # 4. GNOME TERMINAL (VTE TrueColor & Chafa)
  # Profil Catppuccin Mocha déclaré via dconf
  dconf.settings = {
    # Définition du terminal par défaut pour GNOME / Cinnamon
    "org/gnome/desktop/default-applications/terminal" = {
      exec = configuredTerminal;
      exec-arg = "-e";
    };

    "org/gnome/terminal/legacy/profiles:" = {
      default = gnomeProfileUuid;
      list = [ gnomeProfileUuid ];
    };

    "org/gnome/terminal/legacy/profiles:/:${gnomeProfileUuid}" = {
      visible-name = "Catppuccin Mocha";
      background-color = "rgb(30,30,46)";
      foreground-color = "rgb(205,214,244)";
      highlight-colors-set = true;
      highlight-background-color = "rgb(245,224,220)";
      highlight-foreground-color = "rgb(88,91,112)";
      cursor-colors-set = true;
      cursor-background-color = "rgb(245,224,220)";
      cursor-foreground-color = "rgb(30,30,46)";
      use-theme-colors = false;
      bold-is-bright = true;
      font = "JetBrainsMono Nerd Font 11";
      use-system-font = false;
      palette = [
        "rgb(69,71,90)"
        "rgb(243,139,168)"
        "rgb(166,227,161)"
        "rgb(249,226,175)"
        "rgb(137,180,250)"
        "rgb(245,194,231)"
        "rgb(148,226,213)"
        "rgb(186,194,222)"
        "rgb(88,91,112)"
        "rgb(243,139,168)"
        "rgb(166,227,161)"
        "rgb(249,226,175)"
        "rgb(137,180,250)"
        "rgb(245,194,231)"
        "rgb(148,226,213)"
        "rgb(166,173,200)"
      ];
    };
  };

  # 5. COSMIC TERMINAL (Rust Wgpu & Chafa)
  # Palette et syntaxe Catppuccin Mocha déclarée dans com.system76.CosmicTerm/v1
  xdg.configFile."cosmic/com.system76.CosmicTerm/v1/syntax_theme_dark".text = "\"Catppuccin Mocha\"\n";
  xdg.configFile."cosmic/com.system76.CosmicTerm/v1/font_name".text = "\"JetBrainsMono Nerd Font\"\n";
  xdg.configFile."cosmic/com.system76.CosmicTerm/v1/font_size".text = "11\n";
  xdg.configFile."cosmic/com.system76.CosmicTerm/v1/color_schemes_dark".text = ''
    {
        1: (
            name: "Catppuccin Mocha",
            foreground: Some("#cdd6f4"),
            background: Some("#1e1e2e"),
            cursor: Some("#f5e0dc"),
            bright_foreground: Some("#cdd6f4"),
            dim_foreground: Some("#6c7086"),
            normal: (
                black: Some("#45475a"),
                red: Some("#f38ba8"),
                green: Some("#a6e3a1"),
                yellow: Some("#f9e2af"),
                blue: Some("#89b4fa"),
                magenta: Some("#f5c2e7"),
                cyan: Some("#94e2d5"),
                white: Some("#bac2de"),
            ),
            bright: (
                black: Some("#585b70"),
                red: Some("#f38ba8"),
                green: Some("#a6e3a1"),
                yellow: Some("#f9e2af"),
                blue: Some("#89b4fa"),
                magenta: Some("#f5c2e7"),
                cyan: Some("#94e2d5"),
                white: Some("#a6adc8"),
            ),
            dim: (
                black: Some("#45475a"),
                red: Some("#f38ba8"),
                green: Some("#a6e3a1"),
                yellow: Some("#f9e2af"),
                blue: Some("#89b4fa"),
                magenta: Some("#f5c2e7"),
                cyan: Some("#94e2d5"),
                white: Some("#bac2de"),
            ),
        ),
    }
  '';
}
