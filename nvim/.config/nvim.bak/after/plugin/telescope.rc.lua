if vim.g.vscode then return end

local telescope_ok, telescope = pcall(require, "telescope")
if not telescope_ok then return end

local actions = require("telescope.actions")
local builtin = require("telescope.builtin")

local function telescope_buffer_dir()
	return vim.fn.expand("%:p:h")
end

telescope.setup({
    defaults = {
		file_ignore_patterns = { ".git/", "node_modules" },
        layout_config = {
            width = 0.6,
            height = 0.4,
            prompt_position = "top"
        },
		mappings = {
			i = {
				["<Down>"] = actions.cycle_history_next,
				["<Up>"] = actions.cycle_history_prev,
				["<C-j>"] = actions.move_selection_next,
				["<C-k>"] = actions.move_selection_previous,
				["<C-l>"] = actions.select_default,
				["<esc>"] = actions.close,
			},
		},
        layout_strategy = "horizontal",
        path_display = { "smart" },
        prompt_prefix = " ",
        selection_caret = " ",
        sorting_strategy = "ascending"
	},
    pickers = {}
})

telescope.load_extension("ui-select")
telescope.load_extension("file_browser")

local map = vim.keymap.set

map("n", "<leader>sf", function()
	builtin.find_files()
end)

map("n", "<leader>sg", function()
	builtin.live_grep()
end)

map("n", "<leader>sb", function()
	builtin.buffers()
end)

map("n", "<leader>st", function()
	builtin.help_tags()
end)

map("n", "<leader>ss", function()
	builtin.resume()
end)

map("n", "<leader>sd", function()
	builtin.diagnostics()
end)

map("n", "se", function()
	telescope.extensions.file_browser.file_browser({
		path = "%:p:h",
		cwd = telescope_buffer_dir(),
		respect_gitignore = false,
		hidden = true,
		grouped = true,
		previewer = false,
        theme = "dropdown",
		initial_mode = "normal",
		layout_config = { height = 40 },
	})
end)
