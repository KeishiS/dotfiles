-- encoding
vim.opt.fileencoding = "utf-8"
-- highlight the current line
vim.opt.cursorline = true
-- set numbered lines
vim.opt.number = true
-- not making swapfile
vim.opt.swapfile = false

-- number of shift-indent
vim.opt.shiftwidth = 4
-- replace tab to spaces
vim.opt.expandtab = true
-- number of tab-indent
vim.opt.tabstop = 4
-- enable auto-indent
vim.opt.autoindent = true
-- enable smart-indent
vim.opt.smartindent = true

require '001-lualine'
require 'plugins'

vim.cmd [[colorscheme nord]]
