return {
	"nvim-neo-tree/neo-tree.nvim",
	branch = "v3.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons",
		"MunifTanjim/nui.nvim",
		{ "3rd/image.nvim", opts = {} },
	},
	lazy = false,
	config = function()
		require("neo-tree").setup({
			filesystem = {
				filtered_items = {
					visible = true,
					hide_dotfiles = false,
					hide_gitignored = true,
				},
			},
		})
		vim.keymap.set("n", "<C-n>", ":Neotree filesystem reveal left<CR>")
	end,
}
