vim.opt.undofile = true
vim.opt.clipboard = "unnamedplus"
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.softtabstop = -1
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.conceallevel = 0 -- Don't hide markup
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.timeout = true
vim.opt.timeoutlen = 300
vim.opt.grepprg = "rg --vimgrep --smart-case --glob '!.git/*'"
vim.opt.termguicolors = true

vim.keymap.set("i", "jk", "<Esc>", { noremap = true, silent = true })
vim.keymap.set("n", "gl", vim.diagnostic.open_float, { desc = "Show diagnostic" })
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Prev diagnostic" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Diagnostics list" })
-- Reference: https://neovim.io/doc/user/lsp.html#_lua-module:-vim.lsp.completion
vim.cmd([[set completeopt+=menuone,noselect,popup]])
-- Set up gopls
vim.lsp.config("gopls", {
	cmd = { "gopls" },
	filetypes = { "go" },
	settings = {
		gopls = {
			gofumpt = true,
			codelenses = {
				gc_details = false,
				generate = true,
				regenerate_cgo = true,
				run_govulncheck = true,
				test = true,
				tidy = true,
				upgrade_dependency = true,
				vendor = true,
			},
			hints = {
				assignVariableTypes = true,
				compositeLiteralFields = true,
				compositeLiteralTypes = true,
				constantValues = true,
				functionTypeParameters = true,
				parameterNames = true,
				rangeVariableTypes = true,
			},
			analyses = {
				nilness = true,
				unusedparams = true,
				unusedwrite = true,
				useany = true,
			},
			usePlaceholders = true,
			completeUnimported = true,
			staticcheck = true,
			directoryFilters = { "-.git", "-.vscode", "-.idea", "-.vscode-test", "-node_modules" },
			semanticTokens = true,
		},
	},
})

vim.diagnostic.config({
	underline = true,
	update_in_insert = false,
	virtual_text = {
		spacing = 4,
		source = "if_many",
		prefix = "●",
		-- this will set set the prefix to a function that returns the diagnostics icon based on the severity
		-- this only works on a recent 0.10.0 build. Will be set to "●" when not supported
		-- prefix = "icons",
	},
	severity_sort = true,
})

vim.lsp.enable("gopls")

local on_attach = function(client, bufnr)
	vim.lsp.completion.enable(true, client.id, bufnr, {
		autotrigger = true,
		convert = function(item)
			return { abbr = item.label:gsub("%b()", "") }
		end,
	})
	if client.name == "gopls" and not client.server_capabilities.semanticTokensProvider then
		local semantic = client.config.capabilities.textDocument.semanticTokens
		client.server_capabilities.semanticTokensProvider = {
			full = true,
			legend = { tokenModifiers = semantic.tokenModifiers, tokenTypes = semantic.tokenTypes },
			range = true,
		}
	end
end
vim.lsp.start({
	name = "gopls",
	cmd = { "gopls" },
	on_attach = on_attach,
})
