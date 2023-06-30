-- colors
vim.opt.termguicolors = true -- enables 24-bit RGB color in the TUI.
vim.opt.number = true        -- show linenumbers
vim.opt.mouse = 'a'          -- enables mouse operation in all modes
vim.opt.mousefocus = true    -- the window that the mouse pointer is on is automatically activated.
vim.opt.clipboard:append 'unnamedplus' -- use system clipboard

vim.opt.timeoutlen = 500     -- time in milliseconds to wait for a mapped sequence to complete
vim.opt.updatetime = 250     -- if this many milliseconds nothing is typed the swap file will be written to disk.

vim.opt.shortmess:append 'A' -- don't ask about existing swap files

-- use spaces
local tabsize = 2
vim.opt.tabstop = tabsize
vim.opt.shiftwidth = tabsize
vim.opt.expandtab = true     -- use spaces instead of tab

vim.opt.smartindent = true   -- do smart autoindenting when starting a new line
vim.opt.breakindent = true   -- every wrapped line will continue visually indented, thus preserving horizontal blocks of text

-- space as leader
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- consistent number column
vim.opt.signcolumn = "yes:1"

-- how to show autocomplete menu.
-- menuone: use the popup menu also when there is only one match
-- noinsert: do not insert any text for a match until the user selects a match from the menu.
vim.opt.completeopt = 'menuone,noinsert'

-- split right and below by default
vim.opt.splitright = true
vim.opt.splitbelow = true

vim.opt.winbar = '%f'        -- windowline

-- don't continue comments automatically
vim.opt.formatoptions:remove({'c', 'r', 'o'})

-- hide cmdline when not used
vim.opt.cmdheight = 0

-- scroll before end of window
vim.opt.scrolloff = 5
