-- Basic options
vim.opt.undofile = true
vim.opt.clipboard = "unnamedplus"
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.softtabstop = -1
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.conceallevel = 0
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.timeout = true
vim.opt.timeoutlen = 300
vim.opt.grepprg = "rg --vimgrep --smart-case --glob '!.git/*'"
vim.opt.termguicolors = true

-- Key mappings
vim.keymap.set("i", "jk", "<Esc>", { noremap = true, silent = true })
vim.keymap.set("n", "gl", vim.diagnostic.open_float, { desc = "Show diagnostic" })
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Prev diagnostic" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Diagnostics list" })

-- Completion settings
vim.cmd([[set completeopt+=menuone,noselect,popup]])

-- Diagnostic configuration
vim.diagnostic.config({
	underline = true,
	update_in_insert = false,
	virtual_text = {
		spacing = 4,
		source = "if_many",
		prefix = "●",
	},
	severity_sort = true,
})

-- Common on_attach function for LSP
local on_attach = function(client, bufnr)
	-- Enable LSP completion (only for clients that support it)
	if client.server_capabilities.completionProvider then
		vim.lsp.completion.enable(true, client.id, bufnr, {
			autotrigger = true,
			convert = function(item)
				-- Keep the label as-is for better Python completion display
				return { abbr = item.label }
			end,
		})
	end

	-- LSP keymaps (buffer-local)
	local opts = { buffer = bufnr, silent = true }
	vim.keymap.set("n", "gD", vim.lsp.buf.declaration, vim.tbl_extend("force", opts, { desc = "Go to declaration" }))
	vim.keymap.set("n", "gd", vim.lsp.buf.definition, vim.tbl_extend("force", opts, { desc = "Go to definition" }))
	vim.keymap.set("n", "K", vim.lsp.buf.hover, vim.tbl_extend("force", opts, { desc = "Hover documentation" }))
	vim.keymap.set("n", "gi", vim.lsp.buf.implementation, vim.tbl_extend("force", opts, { desc = "Go to implementation" }))
	vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, vim.tbl_extend("force", opts, { desc = "Rename symbol" }))
	vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, vim.tbl_extend("force", opts, { desc = "Code action" }))
	vim.keymap.set("n", "gr", vim.lsp.buf.references, vim.tbl_extend("force", opts, { desc = "Find references" }))
	vim.keymap.set("n", "<leader>f", function()
		vim.lsp.buf.format({ async = true })
	end, vim.tbl_extend("force", opts, { desc = "Format buffer" }))

	-- Gopls-specific semantic tokens setup
	if client.name == "gopls" and not client.server_capabilities.semanticTokensProvider then
		local semantic = client.config.capabilities.textDocument.semanticTokens
		client.server_capabilities.semanticTokensProvider = {
			full = true,
			legend = { tokenModifiers = semantic.tokenModifiers, tokenTypes = semantic.tokenTypes },
			range = true,
		}
	end
end

-- ================================
-- Go LSP Configuration (gopls)
-- ================================
vim.lsp.config("gopls", {
	cmd = { "gopls" },
	filetypes = { "go", "gomod", "gowork", "gotmpl" },
	root_markers = { "go.work", "go.mod", ".git" },
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

-- ================================
-- Python LSP Configuration (pyright)
-- ================================
vim.lsp.config("pyright", {
	cmd = { "pyright-langserver", "--stdio" },
	filetypes = { "python" },
	root_markers = {
		"pyproject.toml",
		"setup.py",
		"setup.cfg",
		"requirements.txt",
		"Pipfile",
		"pyrightconfig.json",
		".git",
	},
	settings = {
		python = {
			analysis = {
				autoSearchPaths = true,
				useLibraryCodeForTypes = true,
				diagnosticMode = "openFilesOnly", -- or "workspace"
				typeCheckingMode = "basic", -- "off", "basic", or "strict"
			},
		},
	},
})

vim.lsp.enable("pyright")

-- ================================
-- Ruff LSP Configuration
-- ================================
vim.lsp.config("ruff", {
	cmd = { "ruff", "server" },
	filetypes = { "python" },
	root_markers = {
		"pyproject.toml",
		"ruff.toml",
		".ruff.toml",
		"setup.py",
		"setup.cfg",
		"requirements.txt",
		"Pipfile",
		".git",
	},
	settings = {
		-- Ruff language server settings
		-- You can configure ruff rules in pyproject.toml or ruff.toml instead
	},
	on_attach = function(client, bufnr)
		-- Disable hover in favor of Pyright
		client.server_capabilities.hoverProvider = false
		-- Call the common on_attach
		on_attach(client, bufnr)
	end,
})

vim.lsp.enable("ruff")

-- ================================
-- Auto-format on Save (optional)
-- ================================

-- Auto-format Python files on save with Ruff
vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "*.py",
	callback = function()
		vim.lsp.buf.format({ 
			async = false,
			filter = function(client)
				return client.name == "ruff"
			end,
		})
	end,
})

-- Organize imports on save for Python
vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "*.py",
	callback = function()
		vim.lsp.buf.code_action({
			context = { only = { "source.organizeImports" } },
			apply = true,
		})
	end,
})

-- ================================
-- Attach on_attach to LSP clients
-- ================================

vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		local bufnr = args.buf
		
		if client then
			-- Disable Ruff's hover to avoid conflicts with Pyright
			if client.name == "ruff" then
				client.server_capabilities.hoverProvider = false
			end
			
			on_attach(client, bufnr)
		end
	end,
})

