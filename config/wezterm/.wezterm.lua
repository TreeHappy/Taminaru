local wezterm = require("wezterm")
local config = wezterm.config_builder()
-- local background_opacity = 0.65
local tab_bg = "rgba(0,0,0,0)"
local tab_colors = {
	"Navy",
	"Red",
	"Green",
	"Olive",
	"Maroon",
	"Purple",
	"Teal",
	"Lime",
	"Yellow",
	"Blue",
	"Fuchsia",
	"Aqua",
}

-- [README](~/.config/README.md)
local animal_emojis = {
	"🐱", -- Cat Face
	"🐸", -- Frog Face
	"🦊", -- Fox Face
	"🐹", -- Hamster
	"🐭", -- Mouse Face
	"🐰", -- Rabbit Face
	"🐻", -- Bear Face
	"🐼", -- Panda Face
	"🐨", -- Koala
	"🐯", -- Tiger Face
	"🦁", -- Lion Face
	"🐶", -- Dog Face
}

config.window_decorations = "NONE | RESIZE"
config.default_prog = { "pwsh.exe", "-NoLogo" }
-- config.window_background_opacity = background_opacity
-- config.window_background_image = "c:/Users/Nicolas/Pictures/blade-runner.jpg"
config.color_scheme = "Catppuccin Mocha (Gogh)"
config.font_size = 12.0
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true
config.show_tab_index_in_tab_bar = false
config.show_new_tab_button_in_tab_bar = false
config.hide_tab_bar_if_only_one_tab = false
config.default_cursor_style = "BlinkingBar"
-- config.font = wezterm.font("Fira Code IF", { weight = "Light", italic = false })
config.font = wezterm.font("JetBrains Mono", { italic = false })
-- config.font = wezterm.font("JetBrains Mono", { weight = "Bold", italic = false })

config.colors = {
	-- background = "black",
	tab_bar = {
		background = "rgba(0,0,0,0)",
	},
}

config.window_padding = {
	left = 0,
	right = 0,
	top = 0,
	bottom = 0,
}

wezterm.on("format-tab-title", function(tab)
	if tab.is_active then
		local accent = tab_colors[(tab.tab_index % #tab_colors) + 1]
		local animal = animal_emojis[(tab.tab_index % #animal_emojis) + 1]
		return wezterm.format({
			{ Background = { Color = tab_bg } },
			{ Foreground = { AnsiColor = accent } },
			{ Text = wezterm.nerdfonts.ple_left_half_circle_thick },
			{ Background = { AnsiColor = accent } },
			{ Foreground = { Color = tab_bg } },
			{ Text = " " .. animal .. " " },
			{ Background = { Color = tab_bg } },
			{ Foreground = { AnsiColor = accent } },
			{ Text = wezterm.nerdfonts.ple_right_half_circle_thick },
		})
	else
		local accent = "Grey"
		local animal = animal_emojis[(tab.tab_index % #animal_emojis) + 1]
		return wezterm.format({
			{ Background = { Color = tab_bg } },
			{ Foreground = { AnsiColor = accent } },
			{ Text = wezterm.nerdfonts.ple_left_half_circle_thick },
			{ Background = { AnsiColor = accent } },
			{ Foreground = { Color = tab_bg } },
			{ Text = animal },
			{ Background = { Color = tab_bg } },
			{ Foreground = { AnsiColor = accent } },
			{ Text = wezterm.nerdfonts.ple_right_half_circle_thick },
		})
	end
end)

wezterm.on("update-status", function(window)
	-- Grab the utf8 character for the "powerline" left facing
	-- solid arrow.
	local SOLID_LEFT_ARROW = utf8.char(0xe0b2)

	-- Grab the current window's configuration, and from it the
	-- palette (this is the combination of your chosen colour scheme
	-- including any overrides).
	local color_scheme = window:effective_config().resolved_palette
	local bg = color_scheme.background
	local fg = color_scheme.foreground

	window:set_right_status(wezterm.format({
		-- First, we draw the arrow...
		{ Background = { Color = "none" } },
		{ Foreground = { Color = bg } },
		{ Text = SOLID_LEFT_ARROW },
		-- Then we draw our text
		{ Background = { Color = bg } },
		{ Foreground = { Color = fg } },
		{ Text = " " .. wezterm.username() .. "@" .. wezterm.hostname() .. " " },
	}))
end)

return config
