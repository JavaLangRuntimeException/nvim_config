return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
  },
  config = function()
    -- カスタムコマンドを定義
    vim.api.nvim_create_user_command("LazyGitCurrent", function()
      local path = vim.fn.expand('%:p:h')
      vim.cmd('tabnew | terminal lazygit -p ' .. path)
      vim.cmd('startinsert')
    end, {})

    -- Ctrl+T のマッピングを設定
    vim.api.nvim_set_keymap('n', '<C-t>', ':lua require("neo-tree.command").execute({ action = "open_directory_in_new_tab" })<CR>', { noremap = true, silent = true })
    require("neo-tree").setup({
      filesystem = {
        filtered_items = {
          visible = false, -- デフォルトでは隠しファイルを非表示
          hide_dotfiles = true,
          hide_gitignored = true,
        },
      },
      window = {
        mappings = {
          ["<C-g>"] = "open_lazygit",
          ["<C-t>"] = "open_in_wezterm",
          ["<C-h>"] = "toggle_hidden",
        },
      },
      commands = {
        open_lazygit = function(state)
          local node = state.tree:get_node()
          local path = node:get_id()
          vim.cmd('tabnew | terminal lazygit -p ' .. path)
          vim.cmd('startinsert')
        end,
        open_in_wezterm = function(state)
          -- 選択しているノードのパスを取得
          local node = state.tree:get_node()
          local path = node:get_id()
          -- ファイルの場合は親ディレクトリを取得
          if node.type ~= "directory" then
            path = vim.fn.fnamemodify(path, ":h")
          end
          -- WezTerm のコマンドを組み立て
          local cmd = "wezterm cli spawn --cwd " .. vim.fn.shellescape(path)
          -- コマンドを実行
          os.execute(cmd)
          -- メッセージを表示
          vim.notify("WezTerm: 新しいタブを開きました - パス: " .. path, vim.log.levels.INFO)
        end,
        toggle_hidden = function(state)
          local fs_state = require("neo-tree.sources.filesystem").get_state()
          fs_state.filtered_items.visible = not fs_state.filtered_items.visible
          fs_state.filtered_items.hide_dotfiles = not fs_state.filtered_items.hide_dotfiles
          fs_state.filtered_items.hide_gitignored = not fs_state.filtered_items.hide_gitignored
          require("neo-tree.sources.filesystem").refresh(state)
          local visibility = fs_state.filtered_items.visible and "表示" or "非表示"
          vim.notify("隠しファイルを" .. visibility .. "に設定しました", vim.log.levels.INFO)
        end,
      },
    })
  end,
}
