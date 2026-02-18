return {
  "pwntester/octo.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim",
    "nvim-tree/nvim-web-devicons",
  },
  cmd = "Octo",
  keys = {
    { "<Leader>op", "<cmd>Octo pr list<CR>", desc = "PR 一覧を表示" },
    { "<Leader>oc", "<cmd>Octo pr checks<CR>", desc = "PR チェック状態を表示" },
    { "<Leader>or", "<cmd>Octo review start<CR>", desc = "opでPR一覧を開いて該当のPRを選択した状態でPR レビューモードを開始" },
  },
  config = function()
    require("octo").setup({
      -- use_local_fs = true, -- ローカル git リポジトリから diff を取得（GitHub API の 300 ファイル制限を回避）
      enable_builtin = true,
      default_remote = { "upstream", "origin" },
      default_merge_method = "squash",
      ssh_aliases = {},
      picker = "telescope",
      suppress_missing_scope = {
        projects_v2 = true,
      },
      -- PR レビューコメントの表示設定
      pull_requests = {
        order_by = {
          field = "CREATED_AT",
          direction = "DESC",
        },
        always_select_remote_on_create = false,
      },
      -- レビューコメントをバーチャルテキストとして表示
      reviews = {
        auto_show_threads = true, -- レビュースレッドを自動表示
      },
    })
  end,
}
