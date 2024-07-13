local wezterm = require 'wezterm'
local config = {}
--config.default_prog = { '/usr/bin/zsh', '-l' }
config.font = wezterm.font_with_fallback {
  'JetBrainsMono Nerd Font',
  'Noto Font Emoji',
}
config.font_size = 14
config.use_fancy_tab_bar = true
config.enable_wayland = false
config.window_decorations = "RESIZE|MACOS_FORCE_DISABLE_SHADOW"
config.default_cursor_style = 'SteadyBar'
--config.enable_wayland = true
config.window_close_confirmation = "NeverPrompt"
--config.skip_close_confirmation_for_processes_named = {
--'bash',
--'sh',
--'zsh',
--'fish',
--'tmux',
--'starship',
--}
config.window_padding = {
  left = 10,
  right = 10,
  top = 15,
  bottom = 10,
}
--config.color_scheme = 'Tokyo Night'
config.enable_tab_bar = false
return config
