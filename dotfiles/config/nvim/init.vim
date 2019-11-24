call plug#begin()

Plug 'Lokaltog/vim-monotone'
Plug 'Shougo/echodoc.vim'
Plug 'dense-analysis/ale'
Plug 'derekwyatt/vim-scala'
Plug 'fatih/vim-go'
Plug 'machakann/vim-highlightedyank'
Plug 'rust-lang/rust.vim'
Plug 'sheerun/vim-polyglot'
Plug 'tpope/vim-bundler'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-markdown'
Plug 'tpope/vim-projectionist'
Plug 'tpope/vim-rake'
Plug 'tpope/vim-rbenv'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-sensible'
Plug 'tpope/vim-sleuth'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-vinegar'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

Plug 'autozimu/LanguageClient-neovim', {
    \ 'branch': 'next',
    \ 'do': 'bash install.sh',
    \ }

call plug#end()

" Show current mode down the bottom
set showmode

" The encoding written to file
set fileencoding=utf-8

" Tags
set tags+=.tags
set tags+=.git/tags
set tags+=.git/tags-deps

" See hidden chars and other things
set list
set hlsearch
set cursorline

" Live substitution
set inccommand=nosplit

" Disable swap files and things like that
set noswapfile
set nobackup
set nowb

" Persistent undo
silent !mkdir ~/.vim/backups > /dev/null 2>&1
set undodir=~/.vim/backups
set undofile

" Completion
set wildmenu
set wildmode=list:longest
set wildignore=*.o,*.obj,*~
set wildignore+=*vim/backups*
set wildignore+=*sass-cache*
set wildignore+=vendor/rails/**
set wildignore+=vendor/cache/**
set wildignore+=vendor/assets/**
set wildignore+=*.gem
set wildignore+=.tags
set wildignore+=log/**
set wildignore+=tmp/**
set wildignore+=node_modules/**
set wildignore+=target/**

" Set min-width of buffer, very useful when spliting panes
set winwidth=84

" Wrap lines is for fools
set nowrap
set linebreak

" Appearence
set background=dark
set termguicolors
colorscheme monotone

set listchars=tab:>\ ,trail:-,extends:>,precedes:<,nbsp:+

" Column ruler
set colorcolumn=80

" Enable mouse
set mouse=a

" Terminal mode
tnoremap <Esc><Esc> <C-\><C-n><CR>

" Language & Plugins
let g:ruby_host_prog = '~/.rbenv/versions/2.6.5/bin/neovim-ruby-host'

let g:rustfmt_autosave = 1

let g:go_fmt_command = "goimports"
let g:go_fmt_autosave = 1

let g:scala_sort_across_groups = 1
let g:scala_scaladoc_indent = 1

let g:markdown_minlines = 100
let g:markdown_fenced_languages = ['html', 'python', 'bash=sh', 'ruby', 'scala', 'go']

autocmd BufNewFile,BufReadPost *.md set filetype=markdown

set cmdheight=2
let g:echodoc_enable_at_startup = 1
let g:echodoc#type = 'virtual'

let g:ale_sign_error = '!'
let g:ale_sign_warning = '.'
let g:ale_sign_column_always = 1
let g:ale_lint_on_text_changed = 'never'
let g:ale_lint_on_insert_leave = 0
let g:ale_lint_on_enter = 1
let g:ale_linters = {
      \   'ruby': ['rubocop'],
      \}

let g:airline_theme='minimalist'
if !exists('g:airline_symbols')
  let g:airline_symbols = {}
endif
let g:airline_powerline_fonts = 0
let g:airline_symbols_ascii = 1
let g:airline_symbols.linenr = ''
let g:airline_symbols.maxlinenr = ''
let g:airline#extensions#ale#enabled = 0

set hidden
let g:LanguageClient_serverCommands = {
    \ 'ruby': ['~/.rbenv/shims/solargraph', 'stdio'],
    \ 'c': ['clangd'],
    \ }
function SetLSPShortcuts()
  nnoremap <leader>ld :call LanguageClient#textDocument_definition()<CR>
  nnoremap <leader>lr :call LanguageClient#textDocument_rename()<CR>
  nnoremap <leader>lf :call LanguageClient#textDocument_formatting()<CR>
  nnoremap <leader>lt :call LanguageClient#textDocument_typeDefinition()<CR>
  nnoremap <leader>lx :call LanguageClient#textDocument_references()<CR>
  nnoremap <leader>la :call LanguageClient_workspace_applyEdit()<CR>
  nnoremap <leader>lc :call LanguageClient#textDocument_completion()<CR>
  nnoremap <leader>lh :call LanguageClient#textDocument_hover()<CR>
  nnoremap <leader>ls :call LanguageClient_textDocument_documentSymbol()<CR>
  nnoremap <leader>lm :call LanguageClient_contextMenu()<CR>
endfunction()
augroup LSP
  autocmd!
  autocmd FileType c,ruby call SetLSPShortcuts()
augroup END
