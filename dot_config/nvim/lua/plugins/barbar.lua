return {
	"romgrk/barbar.nvim",
	dependencies = {
		"nvim-tree/nvim-web-devicons", -- Optional: for file icons
		"lewis6991/gitsigns.nvim", -- Optional: for git status
	},
	init = function()
		vim.g.barbar_auto_setup = false
	end,
	config = function()
		require("barbar").setup({
			gitsigns = {
				added = { enabled = true, icon = "+" },
				changed = { enabled = true, icon = "~" },
				deleted = { enabled = true, icon = "-" },
			},
			sidebar_filetypes = {
				["neo-tree"] = { event = "BufWipeout" },
			},
		})

		-- Set up keymaps
		local map = vim.api.nvim_set_keymap
		local opts = { noremap = true, silent = true }

		-- Navigate buffers
		map("n", "<A-,>", "<Cmd>BufferPrevious<CR>", opts)
		map("n", "<A-.>", "<Cmd>BufferNext<CR>", opts)

		-- Re-order buffers
		map("n", "<A-<>", "<Cmd>BufferMovePrevious<CR>", opts)
		map("n", "<A->>", "<Cmd>BufferMoveNext<CR>", opts)

		-- Close buffer
		map("n", "<A-c>", "<Cmd>BufferClose<CR>", opts)

		-- Pin/unpin buffer
		map("n", "<A-p>", "<Cmd>BufferPin<CR>", opts)

		-- Buffer pick mode
		map("n", "<C-p>", "<Cmd>BufferPick<CR>", opts)
	end,
	opts = {},
	version = "^1.0.0", -- Optional: ensures compatibility with version 1.x
}

