vim.pack.add{
  { src = 'https://github.com/neovim/nvim-lspconfig' },
}

vim.opt.undofile      = true                          -- Persistent undo history
vim.opt.clipboard     = "unnamedplus"                 -- Sync with system clipboard
vim.opt.tabstop       = 4                             -- Visual width of a tab
vim.opt.shiftwidth    = 4                             -- Indent size
vim.opt.softtabstop   = -1                            -- Use shiftwidth value
vim.opt.expandtab     = true                          -- Tabs → spaces
vim.opt.ignorecase    = true                          -- Case-insensitive search...
vim.opt.smartcase     = true                          -- ...unless uppercase is typed
vim.opt.conceallevel  = 0                             -- Never hide text
vim.opt.timeout       = true
vim.opt.timeoutlen    = 300                           -- Leader key timeout (ms)
vim.opt.termguicolors = true                          -- 24-bit colour support
vim.opt.grepprg       = "rg --vimgrep --smart-case --glob '!.git/*'"
vim.opt.path:append("**")                             -- Search subdirs recursively
vim.opt.wildmenu      = true                          -- Tab-complete menu
vim.opt.completeopt   = { "menuone", "noselect", "popup" }
vim.opt.complete:append('o')
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

vim.lsp.enable('pyright')

vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('my.lsp', {}),
    callback = function(ev)
        local client = assert(vim.lsp.get_client_by_id(ev.data.client_id))

        -- Enable auto-completion. Note: Use CTRL-Y to select an item. |complete_CTRL-Y|
        if client:supports_method('textDocument/completion') then
            -- Optional: trigger autocompletion on EVERY keypress. May be slow!
            -- local chars = {}; for i = 32, 126 do table.insert(chars, string.char(i)) end
            -- client.server_capabilities.completionProvider.triggerCharacters = chars

            vim.lsp.completion.enable(true, client.id, ev.buf, {autotrigger = true})
        end

    end,
})
