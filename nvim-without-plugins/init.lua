vim.opt.undofile      = true
vim.opt.clipboard     = "unnamedplus"
vim.opt.expandtab   = true
vim.opt.shiftwidth  = 2
vim.opt.softtabstop = -1
vim.opt.ignorecase  = true
vim.opt.smartcase   = true
vim.opt.conceallevel = 0  -- Don't hide markup
vim.cmd("colorscheme desert")
vim.api.nvim_create_autocmd("BufEnter", {callback = function() vim.treesitter.stop() end})
vim.keymap.set('n', '<space>y', function() vim.fn.setreg('+', vim.fn.expand('%:p')) end)
vim.keymap.set("n", "<space>c", function() vim.cmd("noswapfile enew | setlocal buftype=nofile bufhidden=wipe | call feedkeys(':r !', 'n')") end)
vim.keymap.set('i', 'jk', '<Esc>', { noremap = true, silent = true })

vim.opt.timeout = true
vim.opt.timeoutlen = 300

vim.opt.grepprg = "rg --vimgrep --smart-case --glob '!.git/*'"

vim.opt.termguicolors = true

function goplsLSP() 
  vim.lsp.config('gopls', {
    cmd = { 'gopls' },
    filetypes = { 'go' },
    settings = {
    gopls = {
      analyses = {
        unusedparams = true,
      },
      staticcheck = true,
      gofumpt = true,
        },
    },
  })

  vim.lsp.enable('gopls')

  -- Reference: https://neovim.io/doc/user/lsp.html#_lua-module:-vim.lsp.completion
  vim.cmd[[set completeopt+=menuone,noselect,popup]]
  vim.lsp.start({
    name = 'gopls',
    cmd = { 'gopls'},
    on_attach = function(client, bufnr)
      vim.lsp.completion.enable(true, client.id, bufnr, {
        autotrigger = true,
        convert = function(item)
          return { abbr = item.label:gsub('%b()', '') }
        end,
      })
    end,
  })
end

goplsLSP()
