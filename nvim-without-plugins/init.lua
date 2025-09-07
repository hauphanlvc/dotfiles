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
vim.keymap.set("i", "jk", "<Esc>", { noremap = true, silent = true })

vim.opt.timeout = true
vim.opt.timeoutlen = 300

vim.opt.grepprg = "rg --vimgrep --smart-case --glob '!.git/*'"

vim.opt.termguicolors = true

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

vim.lsp.enable("gopls")

vim.lsp.start({
	name = "gopls",
	cmd = { "gopls" },
	on_attach = function(client, bufnr)
		vim.lsp.completion.enable(true, client.id, bufnr, {
			autotrigger = true,
			convert = function(item)
				return { abbr = item.label:gsub("%b()", "") }
			end,
		})
		if not client.server_capabilities.semanticTokensProvider then
			local semantic = client.config.capabilities.textDocument.semanticTokens
			client.server_capabilities.semanticTokensProvider = {
				full = true,
				legend = { tokenModifiers = semantic.tokenModifiers, tokenTypes = semantic.tokenTypes },
				range = true,
			}
		end
	end,
})
