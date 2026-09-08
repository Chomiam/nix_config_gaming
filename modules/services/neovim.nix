{ config, lib, pkgs, ... }:

let
  cfg = config.chomiamos.services.neovim;
in
{
  # =========================================================================
  # 📝 NEOVIM & NVIM PLUGINS
  # =========================================================================

  config = lib.mkIf cfg.enable {
    programs.neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;

      configure = {
        packages.myPlugins = with pkgs.vimPlugins; {
          start = [
            catppuccin-nvim
            nvim-web-devicons
            snacks-nvim
            grug-far-nvim
          ];
        };

        customRC = ''
          lua << EOF
          -----------------------------------------------------------------------
          -- A. OPTIONS DE NAVIGATION & SOURIS
          -----------------------------------------------------------------------
          vim.opt.number = true
          vim.opt.relativenumber = true
          vim.opt.mouse = "a"

          vim.keymap.set("n", "<2-LeftMouse>", "<LeftMouse>i", { desc = "Double-clic pour éditer" })

          -----------------------------------------------------------------------
          -- B. GESTION DES TABULATIONS ET DE L'INDENTATION
          -----------------------------------------------------------------------
          vim.opt.expandtab = true
          vim.opt.shiftwidth = 2
          vim.opt.tabstop = 2
          vim.opt.softtabstop = 2
          vim.opt.autoindent = true
          vim.opt.smartindent = true

          -----------------------------------------------------------------------
          -- C. THÈME ET APPARENCE
          -----------------------------------------------------------------------
          vim.cmd.colorscheme("catppuccin-mocha")

          -----------------------------------------------------------------------
          -- D. CONFIGURATION DE SNACKS.NVIM (Picker & Recherche rapide)
          -----------------------------------------------------------------------
          local snacks = require("snacks")
          
          snacks.setup({
            picker = { enabled = true },
          })

          vim.keymap.set("n", "<leader>ff", function() snacks.picker.files() end, { desc = "Rechercher des fichiers" })
          vim.keymap.set("n", "<leader>fg", function() snacks.picker.grep() end,  { desc = "Rechercher du texte (Grep)" })
          vim.keymap.set("n", "<leader>fb", function() snacks.picker.buffers() end, { desc = "Lister les buffers ouverts" })

          -----------------------------------------------------------------------
          -- E. CONFIGURATION DE GRUG-FAR (Search & Replace global)
          -----------------------------------------------------------------------
          require("grug-far").setup({})
          vim.keymap.set("n", "<leader>sr", function() require("grug-far").open() end, { desc = "Ouvrir Search & Replace projet" })
          EOF
        '';
      };
    };
  };
}
