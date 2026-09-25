{ config, lib, pkgs, ... }:

let
  cfg = config.chomiamos.services.neovim;
  ollamaCfg = config.chomiamos.services.ollama;
  ollamaModel = if (ollamaCfg.model != null && ollamaCfg.model != "") then ollamaCfg.model else "qwen2.5-coder:7b";
  ollamaPort = toString ollamaCfg.port;
in
{
  # =========================================================================
  # 📝 NEOVIM & NVIM PLUGINS (IDE MODERNE & COMPLET)
  # =========================================================================

  config = lib.mkIf cfg.enable {
    # Outils CLI & Serveurs de langage pour l'autocomplétion et le diagnostic
    environment.systemPackages = with pkgs; [
      # Nix
      nil
      nixfmt

      # Luau & Roblox
      luau
      luau-lsp
      rojo
      selene
      stylua

      # Langages populaires
      lua-language-server
      pyright
      ruff
      rust-analyzer
      clang-tools
      gopls
      typescript-language-server
      vscode-langservers-extracted
      bash-language-server
      shfmt
      shellcheck
      marksman
      yaml-language-server
    ];

    programs.neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;

      configure = {
        packages.myPlugins = with pkgs.vimPlugins; {
          start = [
            # Thème & UI
            catppuccin-nvim
            nvim-web-devicons
            snacks-nvim
            grug-far-nvim

            # Coloration & Analyse syntaxique (Treesitter)
            (nvim-treesitter.withPlugins (p: with p; [
              tree-sitter-nix
              tree-sitter-luau
              tree-sitter-lua
              tree-sitter-python
              tree-sitter-rust
              tree-sitter-c
              tree-sitter-cpp
              tree-sitter-javascript
              tree-sitter-typescript
              tree-sitter-json
              tree-sitter-yaml
              tree-sitter-toml
              tree-sitter-html
              tree-sitter-css
              tree-sitter-markdown
              tree-sitter-markdown-inline
              tree-sitter-bash
              tree-sitter-vim
              tree-sitter-vimdoc
            ]))

            # LSP & Roblox
            nvim-lspconfig
            luau-lsp-nvim
            plenary-nvim

            # Moteur d'autocomplétion & Snippets
            nvim-cmp
            cmp-nvim-lsp
            cmp-buffer
            cmp-path
            cmp_luasnip
            luasnip
            friendly-snippets
            lspkind-nvim
            nvim-autopairs

            # Formatage de code
            conform-nvim

            # Autocomplétion IA locale (Ollama / Qwen 2.5 Coder)
            minuet-ai-nvim
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
          local snacks_ok, snacks = pcall(require, "snacks")
          if snacks_ok then
            snacks.setup({
              picker = { enabled = true },
            })

            vim.keymap.set("n", "<leader>ff", function() snacks.picker.files() end, { desc = "Rechercher des fichiers" })
            vim.keymap.set("n", "<leader>fg", function() snacks.picker.grep() end,  { desc = "Rechercher du texte (Grep)" })
            vim.keymap.set("n", "<leader>fb", function() snacks.picker.buffers() end, { desc = "Lister les buffers ouverts" })
          end

          -----------------------------------------------------------------------
          -- E. CONFIGURATION DE GRUG-FAR (Search & Replace global)
          -----------------------------------------------------------------------
          local grug_ok, grug = pcall(require, "grug-far")
          if grug_ok then
            grug.setup({})
            vim.keymap.set("n", "<leader>sr", function() grug.open() end, { desc = "Ouvrir Search & Replace projet" })
          end

          -----------------------------------------------------------------------
          -- F. CONFIGURATION DE TREESITTER (Coloration & Indentation avancées)
          -----------------------------------------------------------------------
          local ts_configs_ok, ts_configs = pcall(require, "nvim-treesitter.configs")
          if ts_configs_ok then
            ts_configs.setup({
              highlight = {
                enable = true,
                additional_vim_regex_highlighting = false,
              },
              indent = {
                enable = true,
              },
            })
          end

          -----------------------------------------------------------------------
          -- G. FERMETURE AUTOMATIQUE DES PARENTHÈSES (nvim-autopairs)
          -----------------------------------------------------------------------
          local autopairs_ok, autopairs = pcall(require, "nvim-autopairs")
          if autopairs_ok then
            autopairs.setup({
              check_ts = true,
            })
          end

          -----------------------------------------------------------------------
          -- H. SNIPPETS & MOTEUR D'AUTOCOMPLÉTION (nvim-cmp)
          -----------------------------------------------------------------------
          local cmp_ok, cmp = pcall(require, "cmp")
          local luasnip_ok, luasnip = pcall(require, "luasnip")

          if cmp_ok and luasnip_ok then
            -- Charger les snippets communautaires (friendly-snippets)
            pcall(function()
              require("luasnip.loaders.from_vscode").lazy_load()
            end)

            -- Intégration autopairs avec cmp (fermeture automatique lors de la confirmation d'une fonction)
            if autopairs_ok then
              local cmp_autopairs = require("nvim-autopairs.completion.cmp")
              cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
            end

            local lspkind_ok, lspkind = pcall(require, "lspkind")
            local formatting_opts = {}
            if lspkind_ok then
              formatting_opts = {
                format = lspkind.cmp_format({
                  mode = "symbol_text",
                  maxwidth = 50,
                  ellipsis_char = "...",
                  menu = {
                    nvim_lsp = "[LSP]",
                    luasnip  = "[Snip]",
                    buffer   = "[Buf]",
                    path     = "[Path]",
                  },
                }),
              }
            end

            cmp.setup({
              snippet = {
                expand = function(args)
                  luasnip.lsp_expand(args.body)
                end,
              },
              window = {
                completion = cmp.config.window.bordered(),
                documentation = cmp.config.window.bordered(),
              },
              mapping = cmp.mapping.preset.insert({
                ["<C-b>"] = cmp.mapping.scroll_docs(-4),
                ["<C-f>"] = cmp.mapping.scroll_docs(4),
                ["<C-Space>"] = cmp.mapping.complete(),
                ["<C-e>"] = cmp.mapping.abort(),
                ["<CR>"] = cmp.mapping.confirm({ select = true }),
                ["<Tab>"] = cmp.mapping(function(fallback)
                  if cmp.visible() then
                    cmp.select_next_item()
                  elseif luasnip.expand_or_jumpable() then
                    luasnip.expand_or_jump()
                  else
                    fallback()
                  end
                end, { "i", "s" }),
                ["<S-Tab>"] = cmp.mapping(function(fallback)
                  if cmp.visible() then
                    cmp.select_prev_item()
                  elseif luasnip.jumpable(-1) then
                    luasnip.jump(-1)
                  else
                    fallback()
                  end
                end, { "i", "s" }),
              }),
              sources = cmp.config.sources({
                { name = "nvim_lsp", priority = 1000 },
                { name = "luasnip",  priority = 750 },
                { name = "path",     priority = 500 },
              }, {
                { name = "buffer",   priority = 250, keyword_length = 3 },
              }),
              formatting = formatting_opts,
            })
          end

          -----------------------------------------------------------------------
          -- I. CONFIGURATION LSP NATIVE (Neovim 0.11+ / 0.12+)
          -----------------------------------------------------------------------
          -- Capacités globales de complétion pour tous les serveurs LSP
          local capabilities = vim.lsp.protocol.make_client_capabilities()
          local cmp_lsp_ok, cmp_lsp = pcall(require, "cmp_nvim_lsp")
          if cmp_lsp_ok then
            capabilities = cmp_lsp.default_capabilities(capabilities)
          end
          vim.lsp.config("*", { capabilities = capabilities })

          -- Raccourcis et actions LSP attachés automatiquement à chaque buffer actif
          vim.api.nvim_create_autocmd("LspAttach", {
            desc = "Raccourcis clavier LSP ChomiamOS",
            callback = function(event)
              local map = function(mode, lhs, rhs, desc)
                vim.keymap.set(mode, lhs, rhs, { buffer = event.buf, desc = desc })
              end

              map("n", "gd", vim.lsp.buf.definition, "LSP: Aller à la définition")
              map("n", "gD", vim.lsp.buf.declaration, "LSP: Aller à la déclaration")
              map("n", "gr", vim.lsp.buf.references, "LSP: Trouver les références")
              map("n", "gi", vim.lsp.buf.implementation, "LSP: Trouver l'implémentation")
              map("n", "K",  vim.lsp.buf.hover, "LSP: Documentation au survol")
              map("n", "<leader>ca", vim.lsp.buf.code_action, "LSP: Actions de code")
              map("n", "<leader>rn", vim.lsp.buf.rename, "LSP: Renommer le symbole")
              map("n", "<leader>cd", vim.diagnostic.open_float, "Diagnostic: Afficher l'erreur")
              map("n", "[d", vim.diagnostic.goto_prev, "Diagnostic: Précédent")
              map("n", "]d", vim.diagnostic.goto_next, "Diagnostic: Suivant")
            end,
          })

          -- Diagnostic UI (icônes et bordures arrondies)
          vim.diagnostic.config({
            virtual_text = { prefix = "●" },
            signs = true,
            underline = true,
            update_in_insert = false,
            severity_sort = true,
            float = { border = "rounded" },
          })

          -- 1. Nix (nil_ls)
          vim.lsp.config("nil_ls", {
            settings = {
              ["nil"] = {
                formatting = {
                  command = { "nixfmt" },
                },
              },
            },
          })

          -- 2. Lua (lua_ls)
          vim.lsp.config("lua_ls", {
            settings = {
              Lua = {
                diagnostics = {
                  globals = { "vim" },
                },
                workspace = {
                  checkThirdParty = false,
                  library = vim.api.nvim_get_runtime_file("", true),
                },
                telemetry = { enable = false },
              },
            },
          })

          -----------------------------------------------------------------------
          -- J. CONFIGURATION SPÉCIFIQUE LUAU & ROBLOX (luau-lsp.nvim)
          -----------------------------------------------------------------------
          local luau_lsp_ok, luau_lsp = pcall(require, "luau-lsp")
          if luau_lsp_ok then
            vim.lsp.config("luau-lsp", {
              settings = {
                ["luau-lsp"] = {
                  completion = {
                    imports = {
                      enabled = true,
                    },
                  },
                },
              },
            })

            luau_lsp.setup({
              sourcemap = {
                enabled = true,
                autogenerate = true,
                rojo_path = "rojo",
                rojo_project_file = "default.project.json",
              },
              types = {
                roblox_security_level = "PluginSecurity",
              },
            })

            vim.keymap.set("n", "<leader>lr", "<cmd>LuauLsp regenerate_sourcemap<CR>", { desc = "Roblox: Régénérer sourcemap Rojo" })
          end

          -- Activer les serveurs de langage configurés
          vim.lsp.enable({
            "nil_ls",
            "lua_ls",
            "pyright",
            "rust_analyzer",
            "clangd",
            "ts_ls",
            "html",
            "cssls",
            "jsonls",
            "bashls",
            "gopls",
            "marksman",
            "yamlls",
          })

          -----------------------------------------------------------------------
          -- K. FORMATAGE AUTOMATISÉ DU CODE (conform.nvim)
          -----------------------------------------------------------------------
          local conform_ok, conform = pcall(require, "conform")
          if conform_ok then
            conform.setup({
              formatters_by_ft = {
                nix = { "nixfmt" },
                luau = { "stylua" },
                lua = { "stylua" },
                python = { "ruff_format" },
                rust = { "rustfmt" },
                c = { "clang-format" },
                cpp = { "clang-format" },
                javascript = { "prettier", stop_after_first = true },
                typescript = { "prettier", stop_after_first = true },
                json = { "prettier", stop_after_first = true },
                yaml = { "prettier", stop_after_first = true },
                markdown = { "prettier", stop_after_first = true },
                sh = { "shfmt" },
                bash = { "shfmt" },
              },
              default_format_opts = {
                lsp_format = "fallback",
              },
            })

            vim.keymap.set({ "n", "v" }, "<leader>cf", function()
              conform.format({ async = true, lsp_format = "fallback" })
            end, { desc = "Code: Formater le fichier/sélection" })
          end

          -----------------------------------------------------------------------
          -- L. IA AUTOCOMPLÉTION CODE GHOST-TEXT (minuet-ai.nvim + Ollama Qwen)
          -----------------------------------------------------------------------
          local minuet_ok, minuet = pcall(require, "minuet")
          if minuet_ok then
            minuet.setup({
              provider = "openai_fim_compatible",
              n_completions = 1,
              context_window = 2048,
              provider_options = {
                openai_fim_compatible = {
                  api_key = "TERM",
                  name = "Ollama",
                  end_point = "http://127.0.0.1:${ollamaPort}/v1/completions",
                  model = "${ollamaModel}",
                  stream = true,
                  optional = {
                    max_tokens = 128,
                    top_p = 0.9,
                  },
                },
              },
              virtualtext = {
                auto_trigger_ft = { "*" },
                keymap = {
                  accept = "<A-y>",
                  accept_line = "<A-l>",
                  prev = "<A-[>",
                  next = "<A-]>",
                  dismiss = "<A-e>",
                },
              },
            })
          end
          EOF
        '';
      };
    };
  };
}
