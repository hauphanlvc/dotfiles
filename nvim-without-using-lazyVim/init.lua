-- =============================================================================
-- Neovim Configuration
-- =============================================================================

-- ── Options ──────────────────────────────────────────────────────────────────

local opt = vim.opt

opt.undofile      = true                          -- Persistent undo history
opt.clipboard     = "unnamedplus"                 -- Sync with system clipboard
opt.tabstop       = 4                             -- Visual width of a tab
opt.shiftwidth    = 4                             -- Indent size
opt.softtabstop   = -1                            -- Use shiftwidth value
opt.expandtab     = true                          -- Tabs → spaces
opt.ignorecase    = true                          -- Case-insensitive search...
opt.smartcase     = true                          -- ...unless uppercase is typed
opt.conceallevel  = 0                             -- Never hide text
opt.timeout       = true
opt.timeoutlen    = 300                           -- Leader key timeout (ms)
opt.termguicolors = true                          -- 24-bit colour support
opt.grepprg       = "rg --vimgrep --smart-case --glob '!.git/*'"
opt.path:append("**")                             -- Search subdirs recursively
opt.wildmenu      = true                          -- Tab-complete menu
opt.completeopt   = { "menuone", "noselect", "popup" }

-- ── Diagnostics ──────────────────────────────────────────────────────────────

vim.diagnostic.config({
    underline        = true,
    update_in_insert = false,
    severity_sort    = true,
    virtual_text = {
        spacing = 4,
        source  = "if_many",
        prefix  = "●",
    },
})

-- ── Keymaps ──────────────────────────────────────────────────────────────────

local map = vim.keymap.set

-- Escape shortcut in insert mode
map("i", "jk", "<Esc>", { noremap = true, silent = true })

-- Diagnostic navigation
map("n", "gl", vim.diagnostic.open_float, { desc = "Diagnostic: show float" })
map("n", "[d", vim.diagnostic.goto_prev,  { desc = "Diagnostic: prev" })
map("n", "]d", vim.diagnostic.goto_next,  { desc = "Diagnostic: next" })
map("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Diagnostic: list" })

-- ── LSP ──────────────────────────────────────────────────────────────────────

--- Shared on_attach: sets keymaps and enables completion for every LSP client.
---@param client vim.lsp.Client
---@param bufnr integer
local function on_attach(client, bufnr)
    -- Native completion (Neovim 0.11+)
    if client.server_capabilities.completionProvider then
        vim.lsp.completion.enable(true, client.id, bufnr, {
            autotrigger = true,
            convert = function(item)
                return { abbr = item.label }
            end,
        })
    end

    -- gopls: backfill semantic tokens when the server omits the provider
    if client.name == "gopls" and not client.server_capabilities.semanticTokensProvider then
        local tokens = client.config.capabilities.textDocument.semanticTokens
        client.server_capabilities.semanticTokensProvider = {
            full   = true,
            range  = true,
            legend = {
                tokenTypes     = tokens.tokenTypes,
                tokenModifiers = tokens.tokenModifiers,
            },
        }
    end

    -- ruff: let Pyright own hover
    if client.name == "ruff" then
        client.server_capabilities.hoverProvider = false
    end

    -- Buffer-local LSP keymaps
    local opts = { buffer = bufnr, silent = true }
    local lsp  = vim.lsp.buf

    map("n", "gD",          lsp.declaration,  vim.tbl_extend("force", opts, { desc = "LSP: declaration" }))
    map("n", "gd",          lsp.definition,   vim.tbl_extend("force", opts, { desc = "LSP: definition" }))
    map("n", "K",           lsp.hover,        vim.tbl_extend("force", opts, { desc = "LSP: hover docs" }))
    map("n", "gi",          lsp.implementation, vim.tbl_extend("force", opts, { desc = "LSP: implementation" }))
    map("n", "gr",          lsp.references,   vim.tbl_extend("force", opts, { desc = "LSP: references" }))
    map("n", "<leader>rn",  lsp.rename,       vim.tbl_extend("force", opts, { desc = "LSP: rename" }))
    map("n", "<leader>ca",  lsp.code_action,  vim.tbl_extend("force", opts, { desc = "LSP: code action" }))
    map("n", "<leader>f", function()
        lsp.format({ async = true })
    end, vim.tbl_extend("force", opts, { desc = "LSP: format buffer" }))
end

-- Wire on_attach to every LSP session via the central LspAttach event
vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if client then
            on_attach(client, args.buf)
        end
    end,
})

-- ── LSP Server Configurations ────────────────────────────────────────────────

-- Go (gopls)
vim.lsp.config("gopls", {
    cmd        = { "gopls" },
    filetypes  = { "go", "gomod", "gowork", "gotmpl" },
    root_markers = { "go.work", "go.mod", ".git" },
    settings = {
        gopls = {
            gofumpt       = true,
            staticcheck   = true,
            semanticTokens = true,
            completeUnimported = true,
            usePlaceholders    = true,
            directoryFilters = { "-.git", "-.vscode", "-.idea", "-.vscode-test", "-node_modules" },
            codelenses = {
                generate          = true,
                regenerate_cgo    = true,
                run_govulncheck   = true,
                test              = true,
                tidy              = true,
                upgrade_dependency = true,
                vendor            = true,
                gc_details        = false,
            },
            hints = {
                assignVariableTypes    = true,
                compositeLiteralFields = true,
                compositeLiteralTypes  = true,
                constantValues         = true,
                functionTypeParameters = true,
                parameterNames         = true,
                rangeVariableTypes     = true,
            },
            analyses = {
                nilness       = true,
                unusedparams  = true,
                unusedwrite   = true,
                useany        = true,
            },
        },
    },
})

-- Python – type checking (Pyright)
vim.lsp.config("pyright", {
    cmd       = { "pyright-langserver", "--stdio" },
    filetypes = { "python" },
    root_markers = {
        "pyproject.toml", "setup.py", "setup.cfg",
        "requirements.txt", "Pipfile", "pyrightconfig.json", ".git",
    },
    settings = {
        python = {
            analysis = {
                autoSearchPaths      = true,
                useLibraryCodeForTypes = true,
                diagnosticMode       = "openFilesOnly",
                typeCheckingMode     = "basic",
            },
        },
    },
})

-- Python – linting & formatting (Ruff)
vim.lsp.config("ruff", {
    cmd       = { "ruff", "server" },
    filetypes = { "python" },
    root_markers = {
        "pyproject.toml", "ruff.toml", ".ruff.toml",
        "setup.py", "setup.cfg", "requirements.txt", "Pipfile", ".git",
    },
    settings = {},
})

vim.lsp.enable({ "gopls", "pyright", "ruff" })

-- ── Autocommands ─────────────────────────────────────────────────────────────

-- Python: organise imports then format with Ruff on every save
-- (two separate autocmds so each action runs independently)
vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*.py",
    callback = function()
        vim.lsp.buf.code_action({
            context = { only = { "source.organizeImports" } },
            apply   = true,
        })
    end,
    desc = "Python: organise imports on save",
})

vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*.py",
    callback = function()
        vim.lsp.buf.format({
            async  = false,
            filter = function(client) return client.name == "ruff" end,
        })
    end,
    desc = "Python: Ruff format on save",
})
