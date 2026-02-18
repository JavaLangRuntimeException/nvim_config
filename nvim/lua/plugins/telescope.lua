return {
  "nvim-telescope/telescope.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    require("telescope").setup({
      defaults = {
        -- 検索結果のレイアウト設定
        layout_strategy = "horizontal",
        layout_config = {
          horizontal = {
            prompt_position = "top",
            preview_width = 0.55,
          },
          width = 0.87,
          height = 0.80,
        },
        sorting_strategy = "ascending",
        -- 検索対象から除外するパターン
        file_ignore_patterns = {
          "node_modules",
          ".git/",
          "%.lock",
        },
      },
    })

    -- キーマッピング
    local builtin = require("telescope.builtin")
    vim.keymap.set("n", "<Leader>ff", builtin.find_files, { desc = "Find Files" })
    vim.keymap.set("n", "<Leader>fg", builtin.live_grep, { desc = "Live Grep" })
    vim.keymap.set("n", "<Leader>fb", builtin.buffers, { desc = "Telescope buffers" })
    vim.keymap.set("n", "<Leader>fh", builtin.help_tags, { desc = "Telescope help tags" })
  end,
}
