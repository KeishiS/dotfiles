return {
  {
    'nvim-lualine/lualine.nvim',
    config = function()
      require('lualine').setup {
        options = {
          section_separators = '',
          component_separators = '',
          globalstatus = true,
        },
        sections = {
          lualine_a = { 'mode' },
          -- lualine_b = { 'branch', 'diff', 'diagnostics' },
          lualine_b = {},
          lualine_c = { 'searchcount' },
          lualine_x = { 'filetype' },
          lualine_y = { 'progress' },
          lualine_z = { 'location' }
        },
        extensions = { 'nvim-tree' },
      }
    end
  },

  -- show keybinding help window
  { 'folke/which-key.nvim' },
}
