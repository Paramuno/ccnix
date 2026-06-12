require("git"):setup({
	-- Order of status signs showing in the linemode
	order = 1500,
})

require("relative-motions"):setup({
	show_numbers = "relative",
	show_motion = true,
})

require("easyjump"):setup({
	icon_fg = "#94e2d5", -- color for hint labels
	first_key_fg = "#45475a", -- color for first char of double-key hints
	first_keys = "asdfgercwtvxbq", -- 14 keys
	second_keys = "yuiophjklnm", -- 11 keys
})

require("recycle-bin"):setup()

require("restore"):setup()

require("bookmarks"):setup({
	last_directory = { enable = false, persist = false, mode = "dir" },
	persist = "all",
	desc_format = "parent",
	file_pick_mode = "hover",
	custom_desc_input = true,
	show_keys = true,
	notify = {
		enable = true,
		timeout = 1,
		message = {
			new = "New bookmark '<key>' -> '<folder>'",
			delete = "Deleted bookmark in '<key>'",
			delete_all = "Deleted all bookmarks",
		},
	},
})
