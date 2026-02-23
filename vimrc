" ============================================================================
" GENERAL SETTINGS
" ============================================================================

" Encoding
set encoding=utf-8
set fileencoding=utf-8
set fileencodings=utf-8,latin1

" Tabs & Indentation
set shiftwidth=4              " Indent width
set tabstop=4                 " Tab width
set softtabstop=4             " Soft tab width
set expandtab                 " Use spaces instead of tabs
set smartindent               " Smart autoindenting on new lines
set autoindent                " Copy indent from current line

" File handling
set nobackup
set nowritebackup
set noswapfile                " No swap files
set autoread                  " Auto-reload files changed outside vim
set hidden                    " Allow switching buffers without saving

" UI
set number                    " Show line numbers
set relativenumber            " Relative line numbers
set numberwidth=1
set scrolloff=10              " Keep N lines visible above/below cursor
set sidescrolloff=8           " Keep N columns visible left/right of cursor
set wrap                      " Wrap long lines
set linebreak                 " Wrap at word boundaries
set showmatch                 " Highlight matching brackets
set cursorline                " Highlight current line
set cursorcolumn              " Highlight current column
set showcmd                   " Show partial commands
set ruler                     " Show cursor position
set noshowmode                " Don't show mode (lightline shows it)
set laststatus=2              " Always show status bar
set cmdheight=1               " Command line height
set signcolumn=yes            " Always show sign column
set colorcolumn=120           " Show column guide at 120 chars
set termguicolors             " Enable 24-bit colors (if terminal supports)

" Mouse
set mouse=a

" Clipboard
set clipboard=unnamed

" Command history
set history=1000

" Searching
set hlsearch                  " Highlight matches
set incsearch                 " Incremental searching
set ignorecase                " Case insensitive search...
set smartcase                 " ...unless uppercase is used

" Completion
set wildmenu
set wildmode=list:longest,full
set wildignore=*.docx,*.jpg,*.png,*.gif,*.pdf,*.pyc,*.exe,*.flv,*.img,*.xlsx
set wildignore+=*.o,*.obj,*.beam,*.class " Compiled files
set wildignore+=*/.git/*,*/.hg/*,*/.svn/*
set wildignore+=*/node_modules/*,*/vendor/*,*/deps/*,*/_build/*
set wildignore+=*/tmp/*,*.so,*.swp,*.zip

" Performance
set updatetime=300            " Faster CursorHold events
set timeoutlen=500            " Mapping timeout
set ttimeoutlen=10            " Keycode timeout
set lazyredraw                " Don't redraw during macros
set shortmess+=c              " Don't show completion menu messages

" Splits
set splitright                " Open vertical splits to the right
set splitbelow                " Open horizontal splits below

" Diff
set diffopt+=vertical         " Always vertical diffs

" Undo persistence
if has('persistent_undo')
  set undofile
  set undodir=~/.vim/undodir
  if !isdirectory(&undodir)
    call mkdir(&undodir, 'p')
  endif
endif

" Font (for GVim/MacVim)
set guifont=Monospace\ Regular\ 12

syntax on

" ============================================================================
" FILE TYPE DETECTION
" ============================================================================

filetype on
filetype plugin on
filetype indent on

" Language-specific tab settings
augroup FileTypeSettings
  autocmd!
  " 2-space indentation
  autocmd FileType elixir,eelixir,heex,surface setlocal shiftwidth=2 tabstop=2 softtabstop=2
  autocmd FileType dart setlocal shiftwidth=2 tabstop=2 softtabstop=2
  autocmd FileType html,css,javascript,typescript,json,yaml setlocal shiftwidth=2 tabstop=2 softtabstop=2
  autocmd FileType sql setlocal shiftwidth=2 tabstop=2 softtabstop=2
  autocmd FileType markdown setlocal shiftwidth=2 tabstop=2 softtabstop=2 wrap linebreak
  autocmd FileType vim setlocal shiftwidth=2 tabstop=2 softtabstop=2
  autocmd FileType dockerfile setlocal shiftwidth=4 tabstop=4 softtabstop=4
  autocmd FileType nginx setlocal shiftwidth=4 tabstop=4 softtabstop=4
  " 4-space indentation
  autocmd FileType php setlocal shiftwidth=4 tabstop=4 softtabstop=4
  autocmd FileType c,cpp setlocal shiftwidth=4 tabstop=4 softtabstop=4
  " SQL file type detection
  autocmd BufRead,BufNewFile *.sql set filetype=sql
  autocmd BufRead,BufNewFile *.pgsql set filetype=sql
  " Elixir/Phoenix templates
  autocmd BufRead,BufNewFile *.heex set filetype=heex
  autocmd BufRead,BufNewFile *.leex set filetype=eelixir
  autocmd BufRead,BufNewFile *.sface set filetype=surface
  " Erlang
  autocmd BufRead,BufNewFile *.erl,*.hrl set filetype=erlang
  autocmd BufRead,BufNewFile rebar.config set filetype=erlang
  " Nginx
  autocmd BufRead,BufNewFile */nginx/*.conf,*/nginx/**/*.conf set filetype=nginx
  autocmd BufRead,BufNewFile nginx.conf set filetype=nginx
  autocmd BufRead,BufNewFile */sites-available/*,*/sites-enabled/* set filetype=nginx
  autocmd BufRead,BufNewFile */conf.d/*.conf set filetype=nginx
  " Docker
  autocmd BufRead,BufNewFile Dockerfile* set filetype=dockerfile
  autocmd BufRead,BufNewFile docker-compose*.yml,docker-compose*.yaml set filetype=yaml.docker-compose
  autocmd BufRead,BufNewFile .dockerignore set filetype=gitignore
  " Node.js
  autocmd BufRead,BufNewFile .nvmrc set filetype=text
  autocmd BufRead,BufNewFile .node-version set filetype=text
augroup END

" ============================================================================
" LOAD PLUGINS & CONFIGS
" ============================================================================

" Call the .vimrc.plug file
if filereadable(expand("~/.vimrc.plug"))
  source ~/.vimrc.plug
endif

so ~/.vim/plugin-config.vim
so ~/.vim/maps.vim

" ============================================================================
" THEME
" ============================================================================

colorscheme molokai
set background=dark
" Alternative: gruvbox
"colorscheme gruvbox
"let g:gruvbox_contrast_dark="hard"
"highlight Normal ctermbg=NONE
