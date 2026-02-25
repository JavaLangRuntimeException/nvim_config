return {
  -- mason.nvim の設定
  {
    "williamboman/mason.nvim",
    build = ":MasonUpdate",
  },

  -- mason-lspconfig.nvim の設定
  -- opts を使うことで AstroNvim のデフォルト LSP ハンドラを保持しつつサーバーを追加
  {
    "williamboman/mason-lspconfig.nvim",
    opts = {
      ensure_installed = {
        "lua_ls",       -- Lua
        "pyright",      -- Python
        "ts_ls",        -- TypeScript/JavaScript
        "gopls",        -- Go
        "jdtls",        -- Java
        "omnisharp",    -- C#
        "intelephense", -- PHP
        "texlab",       -- LaTeX
      },
    },
  },

  -- mason-null-ls.nvim の設定
  {
    "jay-babu/mason-null-ls.nvim",
    opts = {
      ensure_installed = { "stylua" },
    },
  },

  -- mason-nvim-dap.nvim の設定
  {
    "jay-babu/mason-nvim-dap.nvim",
    opts = {
      ensure_installed = { "python" },
    },
  },
}
