-- netrw を完全に無効化（neo-tree で置き換えるため）
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- This file simply bootstraps the installation of Lazy.nvim and then calls other files for execution
-- This file doesn't necessarily need to be touched, BE CAUTIOUS editing this file and proceed at your own risk.
local lazypath = vim.env.LAZY or vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if not (vim.env.LAZY or (vim.uv or vim.loop).fs_stat(lazypath)) then
  -- stylua: ignore
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(lazypath)

-- validate that lazy is available
if not pcall(require, "lazy") then
  -- stylua: ignore
  vim.api.nvim_echo({ { ("Unable to load lazy from: %s\n"):format(lazypath), "ErrorMsg" }, { "Press any key to exit...", "MoreMsg" } }, true, {})
  vim.fn.getchar()
  vim.cmd.quit()
end

-- システムクリップボードとの連携を有効にする
vim.opt.clipboard:append("unnamedplus")

vim.keymap.set('n', '<C-c>', '"+y')
vim.keymap.set('v', '<C-c>', '"+y')

vim.keymap.set('n', '<C-a>', 'ggVG')
vim.keymap.set('v', '<C-a>', 'ggVG')

-- 絶対行番号（左）+ 相対行番号（右）を同時に表示
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.statuscolumn = '%s%=%{v:lnum} %{v:relnum ? v:relnum : ""} '

require "lazy_setup"
require "polish"

-- ===== 背景透過 =====
-- カラースキーム読み込み後に背景を透過にする
vim.api.nvim_create_autocmd("ColorScheme", {
  callback = function()
    local transparent_groups = {
      "Normal", "NormalNC", "NormalFloat",
      "SignColumn", "EndOfBuffer",
      "NeoTreeNormal", "NeoTreeNormalNC", "NeoTreeEndOfBuffer",
      "NeoTreeWinSeparator",
      "FloatBorder", "WinSeparator",
    }
    for _, group in ipairs(transparent_groups) do
      vim.api.nvim_set_hl(0, group, { bg = "NONE" })
    end
  end,
})
-- 起動時にも適用（既にカラースキームが読み込み済みの場合）
vim.cmd("doautocmd ColorScheme")

-- ===== :UserHelp コマンド / nvim --userhelp =====
local function show_user_help()
  local lines = {
    "╔══════════════════════════════════════════════════════════════════╗",
    "║                    My Neovim カスタム設定一覧                   ║",
    "╚══════════════════════════════════════════════════════════════════╝",
    "",
    "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━",
    "  基本設定 (init.lua)",
    "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━",
    "  ・システムクリップボード連携    vim.opt.clipboard = unnamedplus",
    "  ・自動保存                      FocusLost / BufLeave / TextChanged で自動 :write",
    "  ・行番号表示                    絶対行番号（左）+ 相対行番号（右）を同時表示",
    "  ・診断メッセージ                行末にインライン表示（● prefix 付き）",
    "  ・ターミナル自動 insert         term:// に戻ると自動で insert モードに入る",
    "  ・netrw 無効化                  neo-tree で置き換え",
    "  ・nvim . で起動                 neo-tree だけ開き空バッファを出さない",
    "",
    "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━",
    "  グローバル キーマッピング (init.lua)",
    "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━",
    "  Ctrl+C              クリップボードにコピー（n/v モード）",
    "  Ctrl+A              全選択 ggVG（n/v モード）",
    "",
    "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━",
    "  Neo-tree (plugins/neo-tree.lua)",
    "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━",
    "  機能:",
    "    ・開いたファイルまでツリーを自動展開 (follow_current_file)",
    "    ・バッファを閉じるとディレクトリを自動で畳む",
    "    ・マウスドラッグでパネル幅を変更可能 (winfixwidth 解除)",
    "    ・10秒ごとに git fetch → git status 自動更新",
    "    ・隠しファイル / gitignored はデフォルト非表示",
    "",
    "  キー (Neo-tree 内):         動作:",
    "  ─────────────────────────────────────────────────",
    "  Ctrl+G                      lazygit を新タブで開く",
    "  Ctrl+T                      WezTerm の新タブでディレクトリを開く",
    "  Ctrl+H                      隠しファイルの表示/非表示を切替",
    "  Ctrl+→                      パネル幅を +5 広げる",
    "  Ctrl+←                      パネル幅を -5 狭める",
    "  Ctrl+0                      パネル幅をデフォルト(30)にリセット",
    "",
    "  キー (Git Status 内):       動作:",
    "  ─────────────────────────────────────────────────",
    "  gA                          git add --all",
    "  ga                          git add (ファイル単位)",
    "  gu                          git unstage",
    "  gr                          git revert",
    "",
    "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━",
    "  Telescope (plugins/telescope.lua)",
    "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━",
    "  Space+ff                    ファイル名でファジー検索",
    "  Space+fg                    ファイル内容を全文検索 (live_grep / ripgrep)",
    "  Space+fb                    開いているバッファを検索",
    "  Space+fh                    ヘルプタグを検索",
    "",
    "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━",
    "  Octo.nvim - GitHub PR (plugins/octo.lua)",
    "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━",
    "  Space+op                    PR 一覧を表示",
    "  Space+oc                    PR チェック状態を表示",
    "  Space+or                    opでPR一覧を開いて該当のPRを選択した状態でPR レビューモードを開始",
    "  :Octo pr edit <番号>        特定の PR を開く",
    "",
    "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━",
    "  Gitsigns (plugins/git-and-diagnostics.lua)",
    "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━",
    "  ・サインカラムに git diff を表示 (▎ / ▁ / ▔ / ┆)",
    "  ・現在行の git blame を行末に薄く表示",
    "    形式:  <author> (<date>) <summary>",
    "",
    "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━",
    "  Copilot (plugins/copilot.lua)",
    "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━",
    "  Shift+Tab                   Copilot の補完候補を確定 (insert モード)",
    "",
    "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━",
    "  WezTerm キーバインド (~/.wezterm.lua)",
    "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━",
    "  Ctrl+Shift+G                lazygit を起動",
    "  Ctrl+B                      gh browse（GitHub をブラウザで開く）",
    "  Ctrl+V                      gh pr view -w（PR をブラウザで開く）",
    "  Cmd+D                       左右にペイン分割",
    "  Cmd+Shift+E                 上下にペイン分割",
    "  Cmd+B                       下 1/3 にペインを開く",
    "  Cmd+Shift+D                 ペインを閉じる",
    "  Cmd+Shift+矢印              ペインサイズを調整",
    "  Cmd+Z                       元に戻す (Ctrl+_)",
    "  Shift+←/→                   単語単位でカーソル移動",
    "  Shift+Backspace             前の単語を削除",
    "  Cmd+Click                   リンクを開く（nvim でファイルを開く）",
    "  右クリック                   クリップボードから貼り付け",
    "",
    "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━",
    "  WezTerm dev レイアウト",
    "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━",
    "  シェルで `dev <dir>` を実行すると以下のレイアウトを自動作成:",
    "  ┌──────────┬──────────────────┬──────────┐",
    "  │ lazygit  │     nvim .       │  claude  │",
    "  │  (左1/4) │    (中央1/2)     │  (右1/4) │",
    "  ├──────────┴──────────────────┴──────────┤",
    "  │           terminal (下1/5)              │",
    "  └────────────────────────────────────────┘",
    "",
    "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━",
    "  カスタムコマンド",
    "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━",
    "  :UserHelp                   このヘルプを表示",
    "  シェルから: nvim +UserHelp   シェルからこのヘルプを表示",
    "  :LazyGitCurrent             カレントファイルのディレクトリで lazygit を開く",
    "",
    "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━",
    "  インストール済みプラグイン",
    "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━",
    "  AstroNvim v4                ベースフレームワーク",
    "  lazy.nvim                   プラグインマネージャー",
    "  neo-tree.nvim               ファイルツリー",
    "  telescope.nvim              ファジーファインダー",
    "  gitsigns.nvim               git diff / blame 表示",
    "  octo.nvim                   GitHub PR レビュー",
    "  copilot.vim                 GitHub Copilot",
    "  nvim-treesitter             シンタックスハイライト",
    "",
    "  閉じるには q または :q を押してください",
  }

  vim.cmd("enew")
  local buf = vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].swapfile = false
  vim.bo[buf].modifiable = false
  vim.bo[buf].filetype = "userhelp"
  vim.api.nvim_buf_set_keymap(buf, "n", "q", "<cmd>bdelete<CR>", { noremap = true, silent = true })
end

vim.api.nvim_create_user_command("UserHelp", show_user_help, { desc = "カスタム設定一覧を表示" })

-- ===== 診断メッセージ（エラー/警告）を該当行の末尾にインライン表示 =====
-- メイン設定は lua/plugins/astrocore.lua の diagnostics テーブルにあり、
-- 以下は LSP サーバー接続後に確実に適用するための安全策
local function apply_diagnostic_config()
  vim.diagnostic.config({
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
  })
end

-- 起動時に適用
apply_diagnostic_config()

-- LSP サーバー接続時にも再適用（AstroNvim が上書きした場合の対策）
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function()
    vim.schedule(apply_diagnostic_config)
  end,
})

-- ターミナルバッファに戻ったとき自動で insert（terminal）モードに入る
-- lazygit タブに戻った際に即操作できるようにする
vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter" }, {
  pattern = "term://*",
  callback = function()
    if vim.bo.buftype == "terminal" then
      vim.cmd("startinsert")
    end
  end,
})

-- 自動保存: フォーカスを失ったとき・バッファを離れたとき・編集後に自動で保存
vim.opt.autowriteall = true
vim.api.nvim_create_autocmd({ "FocusLost", "BufLeave", "InsertLeave", "TextChanged" }, {
  pattern = "*",
  callback = function()
    if vim.bo.modified and vim.bo.buftype == "" and vim.fn.expand("%") ~= "" then
      vim.cmd("silent! write")
    end
  end,
})

-- nvim . でディレクトリを開いた場合、neo-tree だけ表示して untitled を出さない
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function(data)
    if vim.fn.isdirectory(data.file) == 1 then
      vim.cmd.cd(data.file)
      vim.schedule(function()
        -- neo-tree をサイドバーで開く
        require("neo-tree.command").execute({ source = "filesystem", position = "left" })
        -- untitled / ディレクトリの空ウィンドウを閉じる
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          local buf = vim.api.nvim_win_get_buf(win)
          local name = vim.api.nvim_buf_get_name(buf)
          local ft = vim.bo[buf].filetype
          if ft ~= "neo-tree" and (name == "" or vim.fn.isdirectory(name) == 1) then
            if #vim.api.nvim_list_wins() > 1 then
              pcall(vim.api.nvim_win_close, win, true)
            end
          end
        end
      end)
    end
  end,
})
