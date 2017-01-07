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

hi! VertSplit ctermbg=NONE

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

" ###################
" Selecta Integration
" ###################

function! SelectaCommand(choice_command, selecta_args, vim_command)
  let dict = { 'buf': bufnr('%'), 'vim_command': a:vim_command, 'temps': { 'result': tempname() }, 'name': 'SelectaCommand' }

  function! dict.on_exit(id, code)
    bd!

    if a:code != 0
      return 1
    endif

    if filereadable(self.temps.result)
      let l:selection = readfile(self.temps.result)[0]

      exec self.vim_command." ".l:selection
    else
      echom "selecta: error: can't read selection from (".self.temps.result.")"
    endif
  endfunction

  if line('$') != 1 && getline(1) != ''
    exec 'split '.dict.buf
  endif

  call termopen(a:choice_command." | selecta ".a:selecta_args." > ".dict.temps.result, dict)

  setf dict
  startinsert
endfunction

function! SelectaBuffer()
  let bufnrs = filter(range(1, bufnr("$")), 'buflisted(v:val)')
  let buffers = map(bufnrs, 'bufname(v:val)')

  call SelectaCommand('echo "' . join(buffers, "\n") . '"', "", ":b")
endfunction

nnoremap <leader>b :call SelectaBuffer()<cr>
nnoremap <leader>p :call SelectaCommand("__list_repo", "--height full", ":e")<cr>
