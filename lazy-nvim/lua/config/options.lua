-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.opt.shiftwidth = 4 -- Size of an indent
vim.opt.tabstop = 4    -- Number of spaces tabs count for
-- Provides tab-completion for all file-related tasks by adding '**' to the path
vim.opt.path:append("**")

-- Display all matching files when we tab complete
vim.opt.wildmenu       = true

vim.opt.undofile       = true
vim.opt.clipboard      = "unnamedplus"
vim.opt.expandtab      = true
vim.opt.shiftwidth     = 2
vim.opt.softtabstop    = -1
vim.opt.ignorecase     = true
vim.opt.smartcase      = true
vim.opt.conceallevel   = 0 -- Don't hide markup
vim.opt.number         = true
vim.opt.relativenumber = true

vim.opt.timeout        = true
vim.opt.timeoutlen     = 300

vim.opt.grepprg        = "rg --vimgrep --smart-case --glob '!.git/*'"

vim.opt.termguicolors  = true
