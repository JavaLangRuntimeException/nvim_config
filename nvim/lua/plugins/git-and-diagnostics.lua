return {
  -- gitsigns: サインカラムに git diff 表示 + 行末に blame 表示
  {
    "lewis6991/gitsigns.nvim",
    event = "BufRead",
    opts = {
      signs = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "▁" },
        topdelete = { text = "▔" },
        changedelete = { text = "▎" },
        untracked = { text = "┆" },
      },
      -- 現在行の git blame を行末に薄く表示
      current_line_blame = true,
      current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = "eol",
        delay = 300,
      },
      current_line_blame_formatter = "  <author> (<author_time:%Y-%m-%d>) <summary>",
    },
  },
}
