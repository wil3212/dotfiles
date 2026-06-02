-- options.lua     

vim.cmd('colorscheme vim')
-- Line numbers
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.ignorecase = true      -- Case insensitive searching
vim.opt.smartcase = true       -- ...unless capital letters are used
vim.opt.termguicolors = true   -- Better color support
-- This makes the numbers bright yellow (like your Vim)
-- 'guifg' sets the foreground color
vim.api.nvim_set_hl(0, 'LineNr', { fg = '#e3b52d' }) 
vim.api.nvim_set_hl(0, 'CursorLineNr', { fg = '#e3b52d', bold = true })
-- Força o fundo das janelas flutuantes a ser transparente ou igual ao terminal
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
vim.api.nvim_set_hl(0, "FloatBorder", { bg = "none", fg = "#e3b52d" }) -- Usa o seu amarelo nas bordas
-- Optional: If you want the comments or other UI elements to be brighter
-- vim.api.nvim_set_hl(0, 'Comment', { fg = '#888888', italic = true })
vim.g.vimwiki_hl_cb_checked = 1
vim.opt.virtualedit = "all"
-- Use 4 spaces for indentation
vim.opt.tabstop = 4         -- A hard tab character will display as 4 spaces wide
vim.opt.shiftwidth = 4      -- The number of spaces used for auto-indentation (e.g., when using '>>')
vim.opt.expandtab = true    -- Converts all typed tabs into spaces
vim.opt.autoindent = true   -- Enables automatic indentation on new lines
vim.opt.softtabstop = 4     -- Number of spaces a <Tab> counts for when typing in Insert mode

-- Mantém 999 linhas de distância das bordas, forçando o cursor ao centro
vim.opt.scrolloff = 999

 -- Remove o fundo (bg) e a cor de destaque do Conceal
vim.api.nvim_set_hl(0, 'Conceal', { bg = 'none', fg = 'none' })
