local function bootstrap(packages)
  local path = vim.fn.stdpath("data") .. "/site/pack/paqs/start/paq-nvim"
  local is_installed = vim.fn.empty(vim.fn.glob(path)) == 0

  if is_installed then return end

  vim.fn.system { "git", "clone", "--depth=1", "https://github.com/savq/paq-nvim.git", path }

  vim.cmd.packadd("paq-nvim")
  local paq = require("paq")

  paq(packages)
  paq.install()
end

bootstrap { "savq/paq-nvim" }

require "paq" {
  'savq/paq-nvim',
  'RRethy/nvim-base16',
  'nvim-treesitter/nvim-treesitter',
  'nvim-tree/nvim-web-devicons',
  'nvim-lualine/lualine.nvim',
  'prichrd/netrw.nvim',

  'sheerun/vim-polyglot',
  'fatih/vim-go',
  'rust-lang/rust.vim',

  'tpope/vim-fugitive',
  'tpope/vim-markdown',
  'tpope/vim-sensible',
  'tpope/vim-surround',
  'tpope/vim-repeat',
  'tpope/vim-vinegar',
}

vim.loader.enable()

local set = vim.opt

set.showmode = true
set.list = true
set.smartindent = true
set.cursorline = true
set.textwidth = 100
set.scrolloff = 12
set.lazyredraw = true
set.showmatch = true
set.ignorecase = true
set.smartcase = true
set.tabstop = 2
set.softtabstop = 0
set.expandtab = true
set.shiftwidth = 2
set.number = false
set.smartindent = true
set.hidden = true
set.updatetime = 100
set.conceallevel = 2
set.concealcursor = 'nc'
set.previewheight = 5
set.synmaxcol = 500
set.display = 'msgsep'
set.modeline = false
set.mouse = 'nivh'
set.cmdheight = 0
set.splitbelow = true
set.splitright = true
set.timeoutlen = 400
set.fillchars = [[vert:│,horiz:─,eob:~]]
set.switchbuf = 'useopen,uselast'
set.undofile = true

set.termguicolors = true
set.background = 'light'

vim.cmd [[colorscheme base16-grayscale-light]]

local augroup = vim.api.nvim_create_augroup('base16_tweaks', { clear = false })
vim.api.nvim_create_autocmd('ColorScheme', {
  pattern = 'base16*',
  group = augroup,
  callback = function()
    vim.api.nvim_set_hl(0, 'Search', { fg = '#010101', bg = '#FCB000', bold = true, italic = true })
    vim.api.nvim_set_hl(0, 'SpellBad', { bg = 'NONE', underline = true, italic = true })
    vim.api.nvim_set_hl(0, 'Visual', { reverse = true, italic = true })
    vim.api.nvim_set_hl(0, 'CursorLine', { fg = '#252525', bg = 'lightgrey' })
  end
})

require('lualine').setup {
  options = {
    theme = 'base16',
    component_separators = { left = '', right = '' },
    section_separators = { left = '', right = '' },
    -- component_separators = { left = '', right = '' },
    -- section_separators = { left = '', right = '' },
  },
}

require('nvim-web-devicons').setup {
 color_icons = true;
}

require('netrw').setup {
  use_devicons = true,
}
