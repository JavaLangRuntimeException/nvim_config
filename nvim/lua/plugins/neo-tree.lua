return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
  },
  config = function()
    -- 定期的に git fetch を実行し、neo-tree の git status を更新する
    local fetch_timer = vim.uv.new_timer()
    local fetch_interval = 10 * 1000 -- 10秒ごと

    local function git_fetch_and_refresh()
      local cwd = vim.fn.getcwd()
      -- git リポジトリかどうか確認してから fetch
      vim.fn.jobstart({ "git", "-C", cwd, "rev-parse", "--is-inside-work-tree" }, {
        on_exit = function(_, exit_code)
          if exit_code == 0 then
            vim.fn.jobstart({ "git", "-C", cwd, "fetch", "--quiet" }, {
              on_exit = function(_, fetch_code)
                if fetch_code == 0 then
                  vim.schedule(function()
                    -- neo-tree の git status をリフレッシュ
                    local ok, manager = pcall(require, "neo-tree.sources.manager")
                    if ok then
                      pcall(manager.refresh, "filesystem")
                    end
                  end)
                end
              end,
            })
          end
        end,
      })
    end

    -- タイマー開始: 初回は30秒後、以降は3分ごと
    fetch_timer:start(30 * 1000, fetch_interval, vim.schedule_wrap(git_fetch_and_refresh))

    -- Neovim 終了時にタイマーを停止
    vim.api.nvim_create_autocmd("VimLeavePre", {
      callback = function()
        if fetch_timer then
          fetch_timer:stop()
          fetch_timer:close()
        end
      end,
    })

    -- カスタムコマンドを定義
    vim.api.nvim_create_user_command("LazyGitCurrent", function()
      local path = vim.fn.expand('%:p:h')
      vim.cmd('tabnew | terminal lazygit -p ' .. path)
      vim.cmd('startinsert')
    end, {})

    -- Ctrl+T のマッピングを設定
    vim.api.nvim_set_keymap('n', '<C-t>', ':lua require("neo-tree.command").execute({ action = "open_directory_in_new_tab" })<CR>', { noremap = true, silent = true })
    -- バッファを閉じたときに neo-tree のディレクトリ展開を畳み直す
    vim.api.nvim_create_autocmd("BufDelete", {
      callback = function()
        vim.schedule(function()
          local ok, manager = pcall(require, "neo-tree.sources.manager")
          if not ok then return end
          local state = manager.get_state("filesystem")
          if not state or not state.tree then return end
          -- 全ノードを畳む
          local renderer = require("neo-tree.ui.renderer")
          renderer.collapse_all_nodes(state.tree)
          -- 現在のファイルまで再展開させる
          manager.refresh("filesystem")
        end)
      end,
    })

    -- Neo-tree のウィンドウが開いた後に winfixwidth を解除し、マウスドラッグでリサイズ可能にする
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "neo-tree",
      callback = function()
        vim.schedule(function()
          local win = vim.api.nvim_get_current_win()
          vim.wo[win].winfixwidth = false
        end)
      end,
    })

    require("neo-tree").setup({
      -- git status の差分表示を最適化
      default_component_configs = {
        git_status = {
          symbols = {
            added     = "✚",
            modified  = "",
            deleted   = "✖",
            renamed   = "󰁕",
            untracked = "",
            ignored   = "",
            unstaged  = "󰄱",
            staged    = "",
            conflict  = "",
          },
        },
      },
      filesystem = {
        hijack_netrw_behavior = "open_default",
        follow_current_file = {
          enabled = true,          -- 開いたファイルまでツリーを自動展開
          leave_dirs_open = false, -- ファイルを閉じたら不要なディレクトリ展開を畳む
        },
        filtered_items = {
          visible = false, -- デフォルトでは隠しファイルを非表示
          hide_dotfiles = true,
          hide_gitignored = true,
        },
      },
      -- git status ソースの設定
      git_status = {
        follow_current_file = { enabled = true },
        window = {
          mappings = {
            ["gA"] = "git_add_all",
            ["gu"] = "git_unstage_file",
            ["ga"] = "git_add_file",
            ["gr"] = "git_revert_file",
          },
        },
      },
      window = {
        width = 30, -- デフォルトの幅
        auto_expand_width = false, -- 手動リサイズを優先するため無効化
        mappings = {
          ["<C-g>"] = "open_lazygit",
          ["<C-t>"] = "open_in_wezterm",
          ["<C-h>"] = "toggle_hidden",
          ["<C-Right>"] = "increase_width", -- Ctrl+→ で幅を広げる
          ["<C-Left>"] = "decrease_width",  -- Ctrl+← で幅を狭める
          ["<C-0>"] = "reset_width",        -- Ctrl+0 でデフォルト幅にリセット
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
        increase_width = function(state)
          local width = vim.api.nvim_win_get_width(state.winid)
          vim.api.nvim_win_set_width(state.winid, width + 5)
        end,
        decrease_width = function(state)
          local width = vim.api.nvim_win_get_width(state.winid)
          vim.api.nvim_win_set_width(state.winid, math.max(width - 5, 15))
        end,
        reset_width = function(state)
          vim.api.nvim_win_set_width(state.winid, 30)
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
