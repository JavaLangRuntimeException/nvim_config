-- AstroCore provides a central place to modify mappings, vim options, autocommands, and more!
-- Configuration documentation can be found with `:h astrocore`

---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    -- Configure core features of AstroNvim
    features = {
      large_buf = { size = 1024 * 256, lines = 10000 },
      autopairs = true,
      cmp = true,
      diagnostics_mode = 3, -- 0=off, 1=no signs/virtual text, 2=no virtual text, 3=on (フル表示)
      highlighturl = true,
      notifications = true,
    },
    -- ===== 診断メッセージ（エラー/警告）を該当行の末尾にインライン表示 =====
    -- AstroNvim はこのテーブルを vim.diagnostic.config() に渡すため、ここで設定する
    diagnostics = {
      virtual_text = {
        prefix = "●",
        spacing = 2,
        format = function(diagnostic)
          local severity = vim.diagnostic.severity
          if diagnostic.severity == severity.ERROR then
            return "Error: " .. diagnostic.message
          elseif diagnostic.severity == severity.WARN then
            return "Warn: " .. diagnostic.message
          elseif diagnostic.severity == severity.INFO then
            return "Info: " .. diagnostic.message
          elseif diagnostic.severity == severity.HINT then
            return "Hint: " .. diagnostic.message
          end
          return diagnostic.message
        end,
      },
      signs = {
        text = {
          [vim.diagnostic.severity.ERROR] = " ",
          [vim.diagnostic.severity.WARN] = " ",
          [vim.diagnostic.severity.INFO] = " ",
          [vim.diagnostic.severity.HINT] = "󰌶 ",
        },
      },
      underline = true,
      update_in_insert = false,
      severity_sort = true,
      float = {
        border = "rounded",
        source = true,
      },
    },
    -- vim options
    options = {
      opt = {
        relativenumber = true,
        number = true,
        spell = false,
        signcolumn = "yes",
        wrap = false,
        mouse = "a",
      },
      g = {},
    },
    -- Mappings
    mappings = {
      n = {
        -- ===== Buffer navigation =====
        ["]b"] = { function() require("astrocore.buffer").nav(vim.v.count1) end, desc = "Next buffer" },
        ["[b"] = { function() require("astrocore.buffer").nav(-vim.v.count1) end, desc = "Previous buffer" },
        ["<Leader>bd"] = {
          function()
            require("astroui.status.heirline").buffer_picker(
              function(bufnr) require("astrocore.buffer").close(bufnr) end
            )
          end,
          desc = "Close buffer from tabline",
        },

        -- ===== Ctrl+Click → 定義ジャンプ (GoLand / VS Code style) =====
        ["<C-LeftMouse>"] = {
          "<LeftMouse><cmd>lua vim.lsp.buf.definition()<CR>",
          desc = "Go to definition (Ctrl+Click)",
        },
        -- Ctrl+RightClick → 戻る
        ["<C-RightMouse>"] = {
          "<C-o>",
          desc = "Go back (Ctrl+RightClick)",
        },

        -- ===== LSP navigation (GoLand style) =====
        ["gd"] = {
          function() vim.lsp.buf.definition() end,
          desc = "Go to definition",
        },
        ["gi"] = {
          function() vim.lsp.buf.implementation() end,
          desc = "Go to implementation",
        },
        ["gr"] = {
          function() require("telescope.builtin").lsp_references() end,
          desc = "Find references",
        },
        ["gy"] = {
          function() vim.lsp.buf.type_definition() end,
          desc = "Go to type definition",
        },
        ["K"] = {
          function() vim.lsp.buf.hover() end,
          desc = "Hover documentation",
        },
        ["<C-o>"] = { "<C-o>", desc = "Go back" },
        ["<C-i>"] = { "<C-i>", desc = "Go forward" },

        -- ===== Search Everywhere (GoLand Shift+Shift 相当) =====
        ["<Leader><Leader>"] = {
          function()
            require("telescope.builtin").find_files({
              prompt_title = "Search Files",
              hidden = true,
              file_ignore_patterns = { "%.git/", "node_modules/", "%.DS_Store" },
            })
          end,
          desc = "Search files (GoLand: Shift+Shift)",
        },
        -- テキスト検索 (GoLand: Ctrl+Shift+F)
        ["<Leader>/"] = {
          function()
            require("telescope.builtin").live_grep({
              prompt_title = "Search Text",
            })
          end,
          desc = "Search text (grep)",
        },
        -- シンボル・型検索 (GoLand: Ctrl+Shift+Alt+N)
        ["<Leader>ss"] = {
          function()
            require("telescope.builtin").lsp_dynamic_workspace_symbols({
              prompt_title = "Search Symbols / Types",
            })
          end,
          desc = "Search symbols & types",
        },
        -- コマンドパレット (GoLand: Ctrl+Shift+A)
        ["<Leader>:"] = {
          function()
            require("telescope.builtin").commands({
              prompt_title = "Command Palette",
            })
          end,
          desc = "Command palette",
        },
        -- バッファ検索
        ["<Leader>sb"] = {
          function()
            require("telescope.builtin").buffers({
              prompt_title = "Search Buffers",
              sort_mru = true,
            })
          end,
          desc = "Search open buffers",
        },
        -- 最近開いたファイル
        ["<Leader>so"] = {
          function()
            require("telescope.builtin").oldfiles({
              prompt_title = "Recent Files",
            })
          end,
          desc = "Search recent files",
        },
        -- カーソル下の単語で検索
        ["<Leader>sw"] = {
          function()
            require("telescope.builtin").grep_string({
              prompt_title = "Search Current Word",
            })
          end,
          desc = "Search word under cursor",
        },
      },
    },
  },
}
