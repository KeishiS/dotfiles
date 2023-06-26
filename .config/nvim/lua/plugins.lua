vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
	-- Packer can manage itself
	use 'wbthomason/packer.nvim'

	-- Color Theme nord
	use 'shaunsingh/nord.nvim'

    -- Status bar
    use {
        'nvim-lualine/lualine.nvim',
        requires = { 'nvim-tree/nvim-web-devicons', opt = true }
    }

    -- completion
    use {
        "hrsh7th/nvim-cmp",
        requires = {
            {"hrsh7th/cmp-vsnip", after = "nvim-cmp"},
            {"hrsh7th/vim-vsnip", after = "nvim-cmp", requires = "hrsh7th/vim-vsnip-integ"},
            {"kdheepak/cmp-latex-symbols", after = "nvim-cmp"}
        }
    }

    -- LSP setting
    use 'neovim/nvim-lspconfig'
end)
