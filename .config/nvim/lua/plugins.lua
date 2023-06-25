vim.cmd [[packadd packer.nvim]]

require('packer').startup(function(use)
	-- Packer can manage itself
	use 'wbthomason/packer.nvim'

	-- Color Theme nord
	use 'shaunsingh/nord.nvim'

end)
