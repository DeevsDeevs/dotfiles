return {
	{
		"williamboman/mason.nvim",
		lazy = false,
		config = function()
			require("mason").setup()
		end,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		lazy = false,
		opts = {
			auto_install = true,
			ensure_installed = {
				"lua_ls",
				"basedpyright",
				"ruff",
				"clangd",
			},
		},
	},
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		lazy = false,
		opts = {
			ensure_installed = {
				"stylua", -- Lua formatter
			},
			auto_update = true,
			run_on_start = true,
		},
	},
	{
		"neovim/nvim-lspconfig",
		lazy = false,
		config = function()
			local capabilities = require("cmp_nvim_lsp").default_capabilities()

			local lspconfig = require("lspconfig")
			lspconfig.lua_ls.setup({
				capabilities = capabilities,
			})
			lspconfig.basedpyright.setup({
				capabilities = capabilities,
				settings = {
					basedpyright = {
						disableOrganizeImports = true,
					},
					python = {
						analysys = {
							ignore = { "*" },
						},
					},
				},
			})
			lspconfig.ruff.setup({
				capabilities = capabilities,
			})
			lspconfig.clangd.setup({
				capabilities = capabilities,
			})

			vim.diagnostic.config({
				virtual_text = {
					prefix = "●", -- or "▶", ">>", etc.
					spacing = 4,
				},
				signs = true,
				underline = true,
				update_in_insert = false,
				severity_sort = true,
			})

			vim.keymap.set("n", "K", vim.lsp.buf.hover, {})
			vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition, {})
			vim.keymap.set("n", "<leader>gr", vim.lsp.buf.references, {})
			vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, {})
		end,
	},
}
