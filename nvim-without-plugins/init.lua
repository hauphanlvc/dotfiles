vim.cmd("colorscheme quiet")
vim.opt.undofile      = true
vim.opt.clipboard     = "unnamedplus"
vim.opt.laststatus    = 0
vim.opt.expandtab   = true
vim.opt.shiftwidth  = 4
vim.opt.softtabstop = -1
vim.opt.ignorecase  = true
vim.opt.smartcase   = true
vim.opt.conceallevel = 0  -- Don't hide markup
-- vim.cmd("syntax off | highlight Normal guifg=#ffaf00 guibg=#282828")
vim.api.nvim_create_autocmd("BufEnter", {callback = function() vim.treesitter.stop() end})
vim.keymap.set('n', '<space>y', function() vim.fn.setreg('+', vim.fn.expand('%:p')) end)
vim.keymap.set("n", "<space>c", function() vim.cmd("noswapfile enew | setlocal buftype=nofile bufhidden=wipe | call feedkeys(':r !', 'n')") end)

vim.opt.grepprg = "rg --vimgrep --smart-case --glob '!.git/*'"

-- vim.lsp.config('gopls', {
--  settings = {
--     gopls = {
--       analyses = {
--         unusedparams = true,
--       },
--       staticcheck = true,
--       gofumpt = true,
--     },
--   },
-- })
--
-- vim.lsp.enable('gopls')
