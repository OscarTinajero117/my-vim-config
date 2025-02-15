" Set shift width to 4 spaces
set shiftwidth=4

" Set tab width to 4 columns
set tabstop=4

" Use space characters instead of tabs
set expandtab

" Do not save backup files
set nobackup

" Do not let cursor scroll below or above N number of lines when scrolling
set scrolloff=10

" Do not wrap lines. Allow long lines to extend as far as the line goes
set nowrap

" Set the commands to save in history (default number is 20)
set history=1000

" Enable auto completion menu after pressing TAB
set wildmenu

" Make wildmenu behave like similar to Bash completion
set wildmode=list:longest

" There are certain files that we would never vant to edit with Vim.
" Wildmenu will ignore files with these extensions.
set wildignore=*.docx,*.jpg,*.png,*.gif,*.pdf,*.pyc,*.exe,*.flv,*.img,*.xlsx

" Automatically wrap text that extends beyond the screen lenght
set wrap

" Encoding
set encoding=utf-8

" Show line numbers
set number

set numberwidth=1

" Use mouse
set mouse=a

" Status bar
set laststatus=2

set clipboard=unnamed

syntax on

set showcmd

set ruler

set cursorline

set cursorcolumn

set showmatch

set relativenumber

set noshowmode

" Set a custom font you have installed on your computer
" Syntax: set guifont=<font_name>\ <font_weight>\ <size>
set guifont=Monospace\ Regular\ 12

" Searching
set hlsearch	" highlight matches
set incsearch	" incremental searching
set ignorecase	" searches are case insensitive...
set smartcase	" ... unless they contain at least one capital letter

so ~/.vim/plugin-config.vim
so ~/.vim/maps.vim

" Call the .vimrc.plug file
if filereadable(expand("~/.vimrc.plug"))
	source ~/.vimrc.plug
endif

colorscheme molokai
set background=dark
"colorscheme gruvbox
"let g:gruvbox_contrast_dark="hard"
"highlight Normal ctermbg=NONE

" New Config
" Enable type file detection
filetype on

" Enable plugins and load plugin for the detected file type
filetype plugin on

" Load an indent file for the detected file type
filetype indent on
