local wezterm = require("wezterm")
local config = wezterm.config_builder()
local background_opacity = 0.5
-- local background_opacity = 0.65
local tab_bg = "rgba(0,0,0,0)"
-- local tab_bg = "#081632"
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
-- Generate a random seed on boot
local random_seed = os.time()
math.randomseed(random_seed)

local animal_emojis = {
	"🐶",
	"🐱",
	"🐭",
	"🐹",
	"🐰",
	"🦊",
	"🐻",
	"🐼",
	"🐨",
	"🐯",
	"🦁",
	"🐮",
	"🐷",
	"🐸",
	"🐵",
	"🙈",
	"🙉",
	"🙊",
	"🐒",
	"🐔",
	"🐧",
	"🐦",
	"🐤",
	"🐣",
	"🐥",
	"🦆",
	"🦅",
	"🦉",
	"🦜",
	"🐓",
	"🦃",
	"🐢",
	"🐍",
	"🦎",
	"🦖",
	"🦕",
	"🐙",
	"🦑",
	"🦐",
	"🦞",
	"🦀",
	"🐡",
	"🐠",
	"🐟",
	"🐬",
	"🐳",
	"🐋",
	"🦈",
	"🐌",
	"🐛",
	"🦋",
	"🐜",
	"🐝",
	"🐞",
	"🦗",
	"🕷️",
	"🕸️",
	"🦂",
	"🦟",
	"🦠",
	"🐘",
	"🦏",
	"🦍",
	"🐪",
	"🐫",
	"🦒",
	"🦓",
	"🦓",
	"🐃",
	"🐅",
	"🐎",
	"🐖",
	"🐏",
	"🐑",
	"🐐",
	"🦌",
	"🐕",
	"🐩",
	"🐈",
	"🐓",
	"🦃",
	"🕊️",
	"🐇",
	"🦝",
	"🦔",
	"🦦",
	"🦥",
	"🦨",
	"🦡",
	"🦫",
	"🐁",
	"🐀",
	"🐿️",
	"🦔",
	"🐾",
}

local emotion_emojis = {
	"😀",
	"😃",
	"😄",
	"😁",
	"😆",
	"😅",
	"😂",
	"🤣",
	"😇",
	"😊",
	"😋",
	"😌",
	"😍",
	"🥰",
	"😘",
	"😗",
	"😙",
	"😚",
	"☺️",
	"🙂",
	"🤗",
	"🤩",
	"🤔",
	"🤨",
	"😐",
	"😑",
	"😶",
	"🙄",
	"😏",
	"😣",
	"😥",
	"😮",
	"🤐",
	"😯",
	"😪",
	"😫",
	"😴",
	"😌",
	"😛",
	"😜",
	"😝",
	"🤤",
	"😒",
	"😓",
	"😔",
	"😕",
	"🙃",
	"🤑",
	"😲",
	"☹️",
	"🙁",
	"😖",
	"😞",
	"😟",
	"😤",
	"😢",
	"😭",
	"😦",
	"😧",
	"😨",
	"😩",
	"🤯",
	"😬",
	"😰",
	"😱",
	"😳",
	"🤪",
	"😵",
	"😡",
	"😠",
}

local function get_random_emoticon_and_animal(seed)
	-- Use the provided seed to generate a random index for the emotion and animal emojis
	math.randomseed(seed)
	local emotion_index = math.random(1, #emotion_emojis)
	local animal_index = math.random(1, #animal_emojis)

	-- Combine the emotion and animal emojis into a string
	local result = emotion_emojis[emotion_index] .. animal_emojis[animal_index]

	-- Return the result
	return result
end

config.window_decorations = "NONE | RESIZE"
config.default_prog = { "nu.exe" }
-- config.default_prog = { "pwsh.exe", "-NoLogo" }
config.window_background_opacity = background_opacity
-- config.window_background_image = "c:/Users/Admin/Downloads/clockwork-golem-542676.gif"
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
-- config.font = wezterm.font("JetBrains Mono", { italic = false })
config.font = wezterm.font("JetBrains Mono", { weight = "Bold", italic = false })

config.colors = {
	-- background = "black",
	tab_bar = {
		background = tab_bg,
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
		local unique_index = (tab.tab_index or 0) + random_seed
		local random_emoticon_and_animal = get_random_emoticon_and_animal(unique_index)
		local accent = tab_colors[(tab.tab_index % #tab_colors) + 1]
		return wezterm.format({
			{ Background = { Color = tab_bg } },
			{ Foreground = { AnsiColor = accent } },
			{ Text = wezterm.nerdfonts.ple_left_half_circle_thick },
			{ Background = { AnsiColor = accent } },
			{ Foreground = { Color = tab_bg } },
			{ Text = " " .. random_emoticon_and_animal .. " " },
			{ Background = { Color = tab_bg } },
			{ Foreground = { AnsiColor = accent } },
			{ Text = wezterm.nerdfonts.ple_right_half_circle_thick },
		})
	else
		local accent = "Grey"
		local unique_index = (tab.tab_index or 0) + random_seed
		local random_emoticon_and_animal = get_random_emoticon_and_animal(unique_index)

		return wezterm.format({
			{ Background = { Color = tab_bg } },
			{ Foreground = { AnsiColor = accent } },
			{ Text = wezterm.nerdfonts.ple_left_half_circle_thick },
			{ Background = { AnsiColor = accent } },
			{ Foreground = { Color = tab_bg } },
			{ Text = random_emoticon_and_animal },
			{ Background = { Color = tab_bg } },
			{ Foreground = { AnsiColor = accent } },
			{ Text = wezterm.nerdfonts.ple_right_half_circle_thick },
		})
	end
end)

wezterm.on("update-status", function(window)
	local color_scheme = window:effective_config().resolved_palette
	local bg = color_scheme.background
	local fg = color_scheme.foreground

	window:set_right_status(wezterm.format({
		{ Background = { Color = tab_bg } },
		{ Foreground = { Color = bg } },
		{ Text = wezterm.nerdfonts.ple_left_half_circle_thick },
		{ Background = { Color = bg } },
		{ Foreground = { Color = fg } },
		{ Text = os.date() },
	}))
end)

return config
