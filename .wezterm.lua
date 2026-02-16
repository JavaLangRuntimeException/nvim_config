local wezterm = require("wezterm")
local config = wezterm.config_builder()

config.automatically_reload_config = true

-- カラースキームの設定
config.color_scheme = 'Solarized Dark'

-- フォントの設定
config.font_size = 10.0

config.use_ime = true

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
  -- CMD+クリックでリンクを開く
  {
    event = { Up = { streak = 1, button = "Left" } },
    mods = "CMD",
    action = wezterm.action.OpenLinkAtMouseCursor,
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

return config
