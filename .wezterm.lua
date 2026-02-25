local wezterm = require("wezterm")
local config = wezterm.config_builder()

config.automatically_reload_config = true

-- カラースキームの設定
config.color_scheme = 'Solarized Dark (Gogh)'

-- フォントの設定
config.font_size = 8.0

config.use_ime = true

-- 変換中の文字（プレエディット）を macOS ネイティブの IME ウィンドウで描画
-- 'Builtin' だと preedit が表示されない場合があるため 'System' を使用
config.ime_preedit_rendering = 'System'

-- macOS: IME に Shift/Ctrl も渡す（日本語変換中のショートカット対応）
config.macos_forward_to_ime_modifier_mask = 'SHIFT|CTRL'

-- ===== フォント設定（日本語表示対応） =====
-- 日本語グリフを含むフォールバックフォントを指定して豆腐（□）を防ぐ
config.font = wezterm.font_with_fallback {
  'JetBrains Mono',          -- 主フォント（英数字）
  'UDEV Gothic',             -- 日本語フォールバック候補1
  'Noto Sans CJK JP',        -- 日本語フォールバック候補2
  'Hiragino Kaku Gothic Pro', -- macOS 標準日本語フォント
}
config.font_size = 12.0

-- East Asian Ambiguous 幅の文字（罫線文字など）を半角扱いにする
-- true にすると lazygit / claude 等の TUI レイアウトが崩れる
config.treat_east_asian_ambiguous_width_as_wide = false

config.window_background_opacity = 0.85

config.window_decorations = "RESIZE"

config.hide_tab_bar_if_only_one_tab = true

-- デフォルトのマウスバインディングを無効化
config.disable_default_mouse_bindings = false

config.window_background_gradient = {
  colors = { "#000000" },
}
config.window_frame = {
  inactive_titlebar_bg = "none",
  active_titlebar_bg = "none",
  
}


config.colors = {
  tab_bar = {
    inactive_tab_edge = "none",
  },
}

-- タブの形をカスタマイズ
-- タブの左側の装飾
local SOLID_LEFT_ARROW = wezterm.nerdfonts.ple_lower_right_triangle
-- タブの右側の装飾
local SOLID_RIGHT_ARROW = wezterm.nerdfonts.ple_upper_left_triangle

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
  local background = "#5c6d74"
  local foreground = "#FFFFFF"
  local edge_background = "none"
  if tab.is_active then
    background = "#ae8b2d"
    foreground = "#FFFFFF"
  end
  local edge_foreground = background
  local title = "   " .. wezterm.truncate_right(tab.active_pane.title, max_width - 1) .. "   "
  return {
    { Background = { Color = edge_background } },
    { Foreground = { Color = edge_foreground } },
    { Text = SOLID_LEFT_ARROW },
    { Background = { Color = background } },
    { Foreground = { Color = foreground } },
    { Text = title },
    { Background = { Color = edge_background } },
    { Foreground = { Color = edge_foreground } },
    { Text = SOLID_RIGHT_ARROW },
  }
end)

config.mouse_bindings = {
  -- 右クリックでクリップボードから貼り付け
  {
    event = { Down = { streak = 1, button = 'Right' } },
    mods = 'NONE',
    action = wezterm.action.PasteFrom 'Clipboard',
  },
  -- CMD+クリック: nvim 内ではスマートナビゲーション（定義ジャンプ / Markdownリンク）
  -- nvim 外ではリンクを開く
  {
    event = { Up = { streak = 1, button = "Left" } },
    mods = "CMD",
    action = wezterm.action_callback(function(window, pane)
      local process = pane:get_foreground_process_name() or ""
      if process:find("nvim") or process:find("vim") then
        -- Down イベントでカーソルがクリック位置に移動済み
        -- ESC でノーマルモードにしてから gd でスマートナビゲーション
        pane:send_text("\x1bgd")
      else
        window:perform_action(wezterm.action.OpenLinkAtMouseCursor, pane)
      end
    end),
  },
}

config.keys = {
  {
    key = 'g',
    mods = 'CTRL|SHIFT',
    action = wezterm.action.Multiple {
      wezterm.action.SendString('lazygit'),
      wezterm.action.SendKey { key = 'Enter' },
    },
  },

  {
    key = 'b',
    mods = 'CTRL',
    action = wezterm.action.Multiple {
      wezterm.action.SendString('gh browse'),
      wezterm.action.SendKey { key = 'Enter' },
    },
  },
  {
    key = 'v',
    mods = 'CTRL',
    action = wezterm.action.Multiple {
      wezterm.action.SendString('gh pr view -w'),
      wezterm.action.SendKey { key = 'Enter' },
    },
  },
  -- SHIFT+左矢印でカーソルを前の単語に移動
  {
    key = 'LeftArrow',
    mods = 'SHIFT',
    action = wezterm.action.SendKey {
      key = 'b',
      mods = 'META',
    },
  },
  -- SHIFT+右矢印でカーソルを次の単語に移動
  {
    key = 'RightArrow',
    mods = 'SHIFT',
    action = wezterm.action.SendKey {
      key = 'f',
      mods = 'META',
    },
  },
  -- SHIFT+Backspaceで前の単語を削除
  {
    key = 'Backspace',
    mods = 'SHIFT',
    action = wezterm.action.SendKey {
      key = 'w',
      mods = 'CTRL',
    },
  },
  -- Cmd+Z を「元に戻す」にマッピング
  {
    key = 'z',
    mods = 'CMD',
    action = wezterm.action.SendString '\x1f', -- Ctrl+_
  },
  {
    key = 'T',
    mods = 'CTRL',
    action = wezterm.action.Multiple({
      wezterm.action.SendKey { key = 't', mods = 'CTRL' },
    }),
  },
  -- Cmd+D で左右に分割（ホームディレクトリで開く）
  {
    key = 'd',
    mods = 'CMD',
    action = wezterm.action.SplitHorizontal {
      cwd = wezterm.home_dir,
    },
  },
  -- Cmd+Shift+E で上下に分割（ホームディレクトリで開く）
  {
    key = 'e',
    mods = 'CMD|SHIFT',
    action = wezterm.action.SplitVertical {
      cwd = wezterm.home_dir,
    },
  },
  -- Cmd+B で下1/3にペインを開く
  {
    key = 'b',
    mods = 'CMD',
    action = wezterm.action.SplitPane {
      direction = 'Down',
      size = { Percent = 33 },
    },
  },
  -- Cmd+Shift+D で分割ペインを閉じる
  {
    key = 'd',
    mods = 'CMD|SHIFT',
    action = wezterm.action.CloseCurrentPane { confirm = false },
  },
  -- Cmd+Shift+上下左右 でペインのサイズを調整
  {
    key = 'LeftArrow',
    mods = 'CMD|SHIFT',
    action = wezterm.action.AdjustPaneSize { 'Left', 5 },
  },
  {
    key = 'RightArrow',
    mods = 'CMD|SHIFT',
    action = wezterm.action.AdjustPaneSize { 'Right', 5 },
  },
  {
    key = 'UpArrow',
    mods = 'CMD|SHIFT',
    action = wezterm.action.AdjustPaneSize { 'Up', 5 },
  },
  {
    key = 'DownArrow',
    mods = 'CMD|SHIFT',
    action = wezterm.action.AdjustPaneSize { 'Down', 5 },
  },
}

config.hyperlink_rules = {
  -- Goの相対パスを検出（キャプチャグループで $1 を使う）
  {
    regex = [[\b([\w\-/\.]+\.go)\b]],
    format = "file://$1",
  },
}

-- Cmd+Click でリンクを開くとき、既存の nvim タブでファイルを開く
wezterm.on("open-uri", function(window, pane, uri)
  wezterm.log_info("open-uri fired: " .. uri)
  local path = uri:gsub("file://", "")

  -- 相対パスならクリック元ペインの作業ディレクトリで絶対パスにする
  if path:sub(1, 1) ~= "/" then
    local cwd_url = pane:get_current_working_dir()
    if cwd_url then
      local cwd = cwd_url.file_path or tostring(cwd_url):gsub("file://[^/]*", "")
      cwd = cwd:gsub("/$", "")
      path = cwd .. "/" .. path
    end
  end

  wezterm.log_info("resolved path: " .. path)

  -- nvim が動いているタブを探す
  local mux_window = window:mux_window()
  for i, tab in ipairs(mux_window:tabs()) do
    for _, tab_pane in ipairs(tab:panes()) do
      local process = tab_pane:get_foreground_process_name()
      if process and process:find("nvim") then
        -- nvim タブに切り替え
        window:perform_action(wezterm.action.ActivateTab(i - 1), pane)
        -- Escape → neo-tree の右のエディタウィンドウでファイルを開く
        tab_pane:send_text("\x1b:lua vim.cmd('wincmd l') vim.cmd('edit " .. path .. "')\r")
        return false
      end
    end
  end

  -- nvim が見つからなければ新しいタブでクリック元の作業ディレクトリを nvim . で開き、該当ファイルも開く
  local cwd_url = pane:get_current_working_dir()
  local cwd = nil
  if cwd_url then
    cwd = cwd_url.file_path or tostring(cwd_url):gsub("file://[^/]*", "")
    cwd = cwd:gsub("/$", "")
  end

  window:perform_action(
    wezterm.action.SpawnCommandInNewTab {
      cwd = cwd or "",
      args = { "/opt/homebrew/bin/nvim", ".", path },
    },
    pane
  )
  return false
end)

-- ===== dev レイアウト =====
-- シェルから `dev {dir}` を実行すると user-var-changed イベント経由で
-- 新しいタブに開発用ペインレイアウトを作成する
--
-- レイアウト:
-- +------------+-----------+-------------------------------+----------+
-- | lazydocker |  lazygit  |            nvim .             |  claude  |
-- |  (左1/6)   |  (1/6)    |          (中央3/6)            |  (右1/6) |
-- |            |           |           上 6/7              |          |
-- +------------+-----------+-------------------------------+----------+
-- |            terminal 1            |        terminal 2              |
-- |           (下1/7 左半分)          |       (下1/7 右半分)            |
-- +----------------------------------+--------------------------------+
wezterm.on("user-var-changed", function(window, pane, name, value)
  if name ~= "dev_layout" then
    return
  end

  local dir = value
  if dir == "" then
    dir = wezterm.home_dir
  end

  local mux_window = window:mux_window()

  -- 新しいタブを作成 → 中央ペイン（nvim 用）
  local tab, center_pane = mux_window:spawn_tab { cwd = dir }

  -- 下 1/7 をターミナル用に分割
  local bottom_pane = center_pane:split {
    direction = "Bottom",
    size = 0.14,  -- ≈ 1/7
    cwd = dir,
  }

  -- 下部を左右半分に分割
  local bottom_right_pane = bottom_pane:split {
    direction = "Right",
    size = 0.50,
    cwd = dir,
  }

  -- 中央から右 1/6 を claude 用に分割
  local right_pane = center_pane:split {
    direction = "Right",
    size = 0.17,  -- ≈ 1/6
    cwd = dir,
  }

  -- 残りの 5/6 から左 2/5 (全体の 2/6) を lazydocker+lazygit 用に分割
  local left_half = center_pane:split {
    direction = "Left",
    size = 0.40,  -- 5/6 の 2/5 = 全体の 2/6
    cwd = dir,
  }

  -- left_half を左右半分に分割: 左=lazydocker, 右(残り)=lazygit
  local lazydocker_pane = left_half:split {
    direction = "Left",
    size = 0.50,
    cwd = dir,
  }

  -- 上部ペインにコマンドを送信
  lazydocker_pane:send_text("lazydocker\n")
  left_half:send_text("lazygit\n")
  center_pane:send_text("nvim .\n")
  right_pane:send_text("claude\n")
  -- 下部ペインはコマンドなし（空ターミナル）
end)

return config
