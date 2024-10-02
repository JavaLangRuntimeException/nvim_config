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
config.show_new_tab_button_in_tab_bar = false
config.show_close_tab_button_in_tabs = false

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

return config
