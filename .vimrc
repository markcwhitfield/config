" .vimrc
" by Andrea Spadaccini <andrea.spadaccini@gmail.com>
"
" Based on an old vimrc.example.

" Vim Settings
" -----------------------------------------------------------------------------

" Remove compatibility with vi.
set nocompatible
set grepprg=grep\ -nH\ $*

" Dark background color. Leads to brighter fonts.
set background=dark

" Colorscheme
colo wombat256

" allow backspacing over everything in insert mode
set backspace=indent,eol,start

" Tabs become 2 spaces
set expandtab
set tabstop=2
set shiftwidth=2

" History of 100 commands
set history=100

" Show info about the cursor position
set ruler

" Display commands as you type them
set showcmd	

" Disable incremental search
set noincsearch

" Set ignorecase and smartcase (ignore case in searches, except if I
" explicitly use uppercase characters).
set ignorecase
set smartcase

" Use shiftwidth when indenting and when inserting a <Tab>
set smarttab

" Window minimum height set to zero, so that when you have multiple windows you
" are not forced to see one row for each file.
set wmh=0

" Max text width: 78 columns.
set textwidth=78

" When inserting a closing parenthesis, briefly flash the closed one
set showmatch

" Used to open quickfix errors in new windows
set switchbuf=split

" Backup in /tmp
set bdir=/tmp,.

" Enhanced mode for command-line tab completion
set wildmenu

" Fix for pyflakes, that screws the quickfix window.
let g:pyflakes_use_quickfix = 0

" Persistent undo
if v:version >= 703
    set undofile
endif

" Key mappings
" -----------------------------------------------------------------------------

" Make shift-insert work like in Xterm
map <S-Insert> <MiddleMouse>
map! <S-Insert> <MiddleMouse>

" Call man for the word under the cursor
map <F1> :exe ":!man ".expand("<cword>")<CR>

" Move to the directory of the file in the current buffer
map <F4> :cd %:p:h<CR>

" Run make
map <F5> :make<CR>

" Use <C-J> (resp. <C-K>) to move one window up (resp. down) and maximize the
" new window
map <C-J> <C-W>j<C-W>_ 
map <C-K> <C-W>k<C-W>_
imap <C-J> <Esc><C-J>a
imap <C-K> <Esc><C-K>a

" Use <C-L> (resp. <C-H>) to move to the next (resp. previous) tab.
map <C-L> :tabn<CR>
map <C-H> :tabp<CR>

" Lets the backspace key start a new undo sequence
inoremap <C-H> <C-G>u<C-H>

" Allows j and k keys to move even inside wrapped lines
map j gj
map k gk

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
  syntax on
  set hlsearch
endif

" Functions
" -----------------------------------------------------------------------------
function! s:LookupPythonModule()
    let l:module_name = expand("<cword>")
    let l:cmd = "/usr/bin/python -c 'import " . l:module_name . "; print " .  l:module_name . ".__file__[:-1]'"
    let l:module = system(l:cmd)
    try
        exe "sp " . l:module
    catch /E172:/
        echo "Not a module, or maybe a builtin module. Couldn't reach it, sorry."
    endtry
endfunction

" Autocommands
" -----------------------------------------------------------------------------

if has("autocmd")
    " Enable file type detection.
    " Use the default filetype settings, so that mail gets 'tw' set to 72,
    " 'cindent' is on in C files, etc.
    " Also load indent files, to automatically do language-dependent indenting.
    filetype plugin indent on
    
    " When editing a file, always jump to the last known cursor position.
    " Don't do it when the position is invalid or when inside an event handler
    " (happens when dropping a file on gvim).
    autocmd BufReadPost *
        \ if line("'\"") > 0 && line("'\"") <= line("$") |
        \   exe "normal g`\"" |
        \ endif
    
    " Forced file types for some extensions
    au BufNewFile,BufRead *.thtml setfiletype php
    au BufNewFile,BufRead *.tex setfiletype tex
    au BufNewFile,BufRead *.as setfiletype actionscript 

    " Filetype-dependent autocommands
    au FileType java set makeprg=ant\ -emacs
    au FileType python match errorMsg /^\t+/
    au FileType python set makeprg=pep8\ --repeat\ %

    au FileType python command! LookupPythonModule :call <SID>LookupPythonModule()
    au Filetype python map <F7> :LookupPythonModule<CR>
    " If there is a local .lvimrc file, source it (useful for project-related vim
    " settings)
    au BufRead,BufNewFile * let x=expand('%:p:h')."/.lvimrc" | if filereadable(x) | exe "source ".substitute(x, ' ', '\\ ', 'g') | endif
    let x=expand('%:p:h')."/.lvimrc" | if filereadable(x) | exe "source ".substitute(x, ' ', '\\ ', 'g') | endif
endif

" Read a local .local_vimrc, if it exists.
if filereadable(expand("~/.local_vimrc")) 
  exe "source ".expand("~/.local_vimrc")
endif
