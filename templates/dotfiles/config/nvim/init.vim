execute pathogen#infect()

" ################
" General settings
" ################

" Show current mode down the bottom
set showmode

" The encoding written to file
set fileencoding=utf-8

" Tags
set tags+=.git/tags
set tags+=.git/tags-deps

" ################
" Editing settings
" ################
set list
set hlsearch

" Disable swap files and things like that
set noswapfile
set nobackup
set nowb

" Persistent undo
silent !mkdir ~/.vim/backups > /dev/null 2>&1
set undodir=~/.vim/backups
set undofile

" Completion
set wildmode=list:longest
set wildmenu
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

" Set min-width of buffer, very useful when spliting panes
set winwidth=84

" Wrap lines is for fools
set nowrap
set linebreak

" ###################
" Appearence settings
" ###################

set t_Co=256
set background=dark
colorscheme base16-grayscale-dark

augroup color_tweaks
  au!
  autocmd ColorScheme * hi VertSplit ctermbg=NONE
  autocmd ColorScheme * hi SignColumn ctermbg=NONE
  autocmd ColorScheme * hi NeomakeErrorSign ctermbg=NONE
  autocmd ColorScheme * hi NeomakeInfoSign ctermbg=NONE
  autocmd ColorScheme * hi NeomakeWarningSign ctermbg=NONE
  autocmd ColorScheme * hi EnErrorStyle ctermbg=10
augroup END

" Statusbar
set statusline=\ %f\  " Filename
set statusline+=%{fugitive#statusline()} " Git info

set statusline+=%= " Separator

set statusline+=%y " File type
set statusline+=[%{strlen(&fenc)?&fenc:'none'}] " File encoding
set statusline+=[%{&ff}] " File ending
set statusline+=\ %P\ of\ %L\  " Perc. file
set statusline+=(%l\:%c)\ " Line info

" Column ruler
set colorcolumn=120

" #######
" Neomake
" #######

autocmd! BufWritePost,BufEnter * Neomake

let g:neomake_warning_sign = {
      \   'text': '*',
      \   'texthl': 'NeomakeWarningSign',
      \ }

" ##################
" Language Specifics
" ##################

let g:scala_sort_across_groups = 1
let g:scala_scaladoc_indent = 1

" ######
" Ensime
" ######

autocmd BufWritePost *.scala silent :EnTypeCheck

au FileType scala nnoremap <localleader>df :EnDeclaration<CR>
au FileType scala nnoremap <localleader>sdf :EnDeclaration<CR>
au FileType scala nnoremap <localleader>tt :EnType<CR>
au FileType scala nnoremap <localleader>ti :EnInspectType<CR>
au FileType scala nnoremap <localleader>oi :EnOrganizeImports<CR>
