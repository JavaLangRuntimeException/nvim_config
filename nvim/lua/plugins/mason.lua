return {
  -- mason.nvim の設定
  {
    "williamboman/mason.nvim",
    build = ":MasonUpdate",
    config = function()
      require("mason").setup()
    end,
  },

  -- mason-lspconfig.nvim の設定
  {
    "williamboman/mason-lspconfig.nvim",
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls",       -- Lua
          "pyright",      -- Python
          "typescript-language-server",     -- TypeScript/JavaScript
          "gopls",        -- Go
          "jdtls",        -- Java
          "omnisharp",    -- C#
          "intelephense", -- PHP
        },
      })
    end,
  },

  -- mason-null-ls.nvim の設定
  {
    "jay-babu/mason-null-ls.nvim",
    config = function()
      require("mason-null-ls").setup({
        ensure_installed = { "stylua" },
      })
    end,
  },

  -- mason-nvim-dap.nvim の設定
  {
    "jay-babu/mason-nvim-dap.nvim",
    config = function()
      require("mason-nvim-dap").setup({
        ensure_installed = { "python" },
      })
    end,
  },
}
