return {
  {
    "github/copilot.vim",
    config = function()
    -- GitHub Copilotの設定
      vim.g.copilot_no_tab_map = true
      vim.api.nvim_set_keymap("i", "<S-Tab>", 'copilot#Accept("<CR>")', { silent = true, expr = true, script = true })
    end,
  },
}
