" ============================================================================
" KEY MAPPINGS
" ============================================================================

let mapleader=" "

" ---- File Operations ----
nnoremap <Leader>w :w<CR>
nnoremap <Leader>q :q<CR>
nnoremap <Leader>Q :q!<CR>

" ---- Testing ----
nnoremap <Leader>t :TestNearest<CR>
nnoremap <Leader>T :TestFile<CR>
nnoremap <Leader>TT :TestSuite<CR>

" ---- Split Resize ----
nnoremap <Leader>> 10<C-w>>
nnoremap <Leader>< 10<C-w><

" ---- Quick Semicolon ----
nnoremap <Leader>; $a;<Esc>

" ---- Shorter Commands ----
cnoreabbrev tree NERDTreeToggle
cnoreabbrev blame Gblame
cnoreabbrev find NERDTreeFind
cnoreabbrev diff Gdiff

" ---- Plugin Navigation ----
map <Leader>nt :NERDTreeFind<CR>
map <Leader>p :Files<CR>
map <Leader>ag :Ag<CR>
map <Leader>rg :Rg<CR>
map <Leader>gf :GFiles<CR>

" ---- Tmux Navigator ----
nnoremap <silent> <Leader><C-h> :TmuxNavigateLeft<cr>
nnoremap <silent> <Leader><C-j> :TmuxNavigateDown<cr>
nnoremap <silent> <Leader><C-k> :TmuxNavigateUp<cr>
nnoremap <silent> <Leader><C-l> :TmuxNavigateRight<cr>

" ---- CoC Mappings ----
" GoTo code navigation
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window
nnoremap <silent> K :call ShowDocumentation()<CR>
function! ShowDocumentation()
  if CocAction('hasProvider', 'hover')
    call CocActionAsync('doHover')
  else
    call feedkeys('K', 'in')
  endif
endfunction

" Symbol renaming
nmap <Leader>rn <Plug>(coc-rename)

" Code actions
nmap <Leader>ca <Plug>(coc-codeaction)
nmap <Leader>cf <Plug>(coc-fix-current)

" Diagnostics navigation
nmap <silent> [d <Plug>(coc-diagnostic-prev)
nmap <silent> ]d <Plug>(coc-diagnostic-next)

" Format selected code
xmap <Leader>f <Plug>(coc-format-selected)
nmap <Leader>f <Plug>(coc-format-selected)

" Use <c-space> to trigger completion
inoremap <silent><expr> <c-space> coc#refresh()

" Use <CR> to confirm completion
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
      \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

" Highlight symbol under cursor on CursorHold
autocmd CursorHold * silent call CocActionAsync('highlight')

" ---- ALE Mappings ----
nmap <Leader>af :ALEFix<CR>
nmap <Leader>al :ALELint<CR>
nmap <silent> [a <Plug>(ale_previous_wrap)
nmap <silent> ]a <Plug>(ale_next_wrap)

" ---- Surround ----
xmap s <Plug>VSurround

" ---- Copy File Path ----
nnoremap <leader>P :let @*=expand("%")<CR>
nnoremap <leader>PP :let @*=expand("%:p")<CR>

" ---- Tab Navigation ----
map <Leader>h :tabprevious<cr>
map <Leader>l :tabnext<cr>
nnoremap <Leader>tn :tabnew<cr>
nnoremap <Leader>tc :tabclose<cr>

" ---- Buffer Navigation ----
map <Leader>ob :Buffers<cr>
nnoremap <Leader>bn :bnext<CR>
nnoremap <Leader>bp :bprevious<CR>
nnoremap <Leader>bd :bdelete<CR>

" ---- Keeping It Centered ----
nnoremap n nzzzv
nnoremap N Nzzzv
nnoremap J mzJ`z

" ---- Moving Text ----
vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv
nnoremap <Leader>k :m .-2<CR>==
nnoremap <Leader>j :m .+1<CR>==

" ---- Faster Scrolling ----
nnoremap <C-j> 10<C-e>
nnoremap <C-k> 10<C-y>

" ---- EasyMotion ----
nmap <Leader>s <Plug>(easymotion-s2)

" ---- Git ----
nnoremap <Leader>G :G<cr>
nnoremap <Leader>gp :Gpush<cr>
nnoremap <Leader>gl :Gpull<cr>
nnoremap <Leader>gb :Git blame<cr>
nnoremap <Leader>gd :Gdiffsplit<cr>
nnoremap <Leader>gs :Git log --oneline -20<cr>

" ---- Run Current File ----
nnoremap <Leader>x :!node %<cr>

" ---- Language-Specific Runners ----
augroup RunCommands
  autocmd!
  autocmd FileType elixir nnoremap <buffer> <Leader>x :!elixir %<CR>
  autocmd FileType php nnoremap <buffer> <Leader>x :!php %<CR>
  autocmd FileType c nnoremap <buffer> <Leader>x :!gcc % -o %:r && ./%:r<CR>
  autocmd FileType cpp nnoremap <buffer> <Leader>x :!g++ % -o %:r && ./%:r<CR>
  autocmd FileType dart nnoremap <buffer> <Leader>x :!dart run %<CR>
  autocmd FileType erlang nnoremap <buffer> <Leader>x :!erl -noshell -s %:r start -s init stop<CR>
augroup END

" ---- Flutter Shortcuts ----
nnoremap <Leader>fr :FlutterRun<CR>
nnoremap <Leader>fq :FlutterQuit<CR>
nnoremap <Leader>fh :FlutterHotReload<CR>
nnoremap <Leader>fR :FlutterHotRestart<CR>
nnoremap <Leader>fD :FlutterVisualDebug<CR>

" ---- Elixir / Phoenix Shortcuts ----
nnoremap <Leader>mf :!mix format %<CR>
nnoremap <Leader>mt :!mix test %<CR>
nnoremap <Leader>mc :!mix compile<CR>
nnoremap <Leader>ms :!mix phx.server<CR>

" ---- Database (vim-dadbod-ui) ----
nnoremap <Leader>du :DBUIToggle<CR>
nnoremap <Leader>df :DBUIFindBuffer<CR>

" ---- Docker ----
nnoremap <Leader>dc :!docker compose up -d<CR>
nnoremap <Leader>dd :!docker compose down<CR>
nnoremap <Leader>dl :!docker compose logs -f --tail=50<CR>
nnoremap <Leader>dp :!docker ps<CR>
nnoremap <Leader>db :!docker compose build<CR>

" ---- Markdown ----
nnoremap <Leader>mp :MarkdownPreview<CR>
nnoremap <Leader>mP :MarkdownPreviewStop<CR>

" ---- Node.js ----
augroup NodeRunCommands
  autocmd!
  autocmd FileType javascript nnoremap <buffer> <Leader>x :!node %<CR>
  autocmd FileType typescript nnoremap <buffer> <Leader>x :!npx ts-node %<CR>
augroup END

" ---- Terminal ----
set splitright
function! OpenTerminal()
  " move to right most buffer
  execute "normal \<C-l>"
  execute "normal \<C-l>"
  execute "normal \<C-l>"
  execute "normal \<C-l>"

  let bufNum = bufnr("%")
  let bufType = getbufvar(bufNum, "&buftype", "not found")

  if bufType == "terminal"
    " close existing terminal
    execute "q"
  else
    " open terminal
    execute "vsp term://zsh"

    " turn off numbers
    execute "set nonu"
    execute "set nornu"

    " toggle insert on enter/exit
    silent au BufLeave <buffer> stopinsert!
    silent au BufWinEnter,WinEnter <buffer> startinsert!

    " set maps inside terminal buffer
    execute "tnoremap <buffer> <C-h> <C-\\><C-n><C-w><C-h>"
    execute "tnoremap <buffer> <C-t> <C-\\><C-n>:q<CR>"
    execute "tnoremap <buffer> <C-\\><C-\\> <C-\\><C-n>"

    startinsert!
  endif
endfunction
nnoremap <C-t> :call OpenTerminal()<CR>

" ---- Clear Search Highlight ----
nnoremap <Leader><space> :nohlsearch<CR>

" ---- Quick Escape ----
inoremap jk <Esc>
inoremap kj <Esc>
