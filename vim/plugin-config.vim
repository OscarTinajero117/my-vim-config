" ============================================================================
" PLUGIN CONFIGURATION
" ============================================================================

" ---- vim-php-refactoring-toolbox ----
" Disable default mappings to avoid conflict with <Leader>du (DBUIToggle)
let g:vim_php_refactoring_use_default_mapping = 0
let g:vim_php_refactoring_auto_validate_visibility = 1

" ---- vim-closetag ----
let g:closetag_filenames = '*.html,*.js,*.jsx,*.ts,*.tsx,*.heex,*.leex,*.eex,*.php'

" ---- Lightline ----
let g:lightline = {
      \ 'active': {
      \   'left': [['mode', 'paste'], ['gitbranch'], ['relativepath', 'modified']],
      \   'right': [['linter_checking', 'linter_errors', 'linter_warnings', 'linter_ok'],
      \             ['filetype', 'percent', 'lineinfo']]
      \ },
      \ 'inactive': {
      \   'left': [['inactive'], ['relativepath']],
      \   'right': [['bufnum']]
      \ },
      \ 'component': {
      \   'bufnum': '%n',
      \   'inactive': 'inactive'
      \ },
      \ 'component_function': {
      \   'gitbranch': 'fugitive#head',
      \ },
      \ 'component_expand': {
      \   'linter_checking': 'lightline#ale#checking',
      \   'linter_warnings': 'lightline#ale#warnings',
      \   'linter_errors': 'lightline#ale#errors',
      \   'linter_ok': 'lightline#ale#ok',
      \ },
      \ 'component_type': {
      \   'linter_checking': 'left',
      \   'linter_warnings': 'warning',
      \   'linter_errors': 'error',
      \   'linter_ok': 'left',
      \ },
      \ 'colorscheme': 'gruvbox',
      \ 'subseparator': {
      \   'left': '',
      \   'right': ''
      \ }
      \}

" ---- NERDTree ----
let NERDTreeShowHidden=1
let NERDTreeQuitOnOpen=1
let NERDTreeAutoDeleteBuffer=1
let NERDTreeMinimalUI=1
let NERDTreeDirArrows=1
let NERDTreeShowLineNumbers=1
let NERDTreeMapOpenInTab='\t'
let NERDTreeIgnore=['\.git$', 'node_modules', '_build', 'deps', '\.elixir_ls', '__pycache__']

" ---- UltiSnips ----
let g:UltiSnipsSnippetDirectories=[$HOME.'/configs/.vim/UltiSnips']
let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsListSnippets="<C-_>"
let g:UltiSnipsJumpForwardTrigger="<tab>"
let g:UltiSnipsJumpBackwardTrigger="<S-tab>"

" ---- CoC (Conquer of Completion) ----
let g:coc_global_extensions = [
      \ 'coc-json',
      \ 'coc-tsserver',
      \ 'coc-html',
      \ 'coc-css',
      \ 'coc-elixir',
      \ 'coc-phpls',
      \ 'coc-clangd',
      \ 'coc-flutter',
      \ 'coc-snippets',
      \ 'coc-sql',
      \ 'coc-erlang_ls',
      \ 'coc-pairs',
      \ 'coc-yaml',
      \ 'coc-docker',
      \ 'coc-markdownlint',
      \ 'coc-vimlsp',
      \ ]

" ---- ALE (Asynchronous Lint Engine) ----
" Let CoC handle LSP, ALE only for linting/fixing
let g:ale_disable_lsp = 1
let g:ale_sign_error = '✘'
let g:ale_sign_warning = '⚠'
let g:ale_echo_msg_format = '[%linter%] %s [%severity%]'

let g:ale_linters = {
      \ 'elixir': ['credo', 'dialyxir'],
      \ 'php': ['php', 'phpcs', 'phpstan'],
      \ 'c': ['cc', 'clangtidy'],
      \ 'cpp': ['cc', 'clangtidy'],
      \ 'dart': ['dart_analyze'],
      \ 'sql': ['sqlint'],
      \ 'erlang': ['erlc', 'dialyzer'],
      \ 'dockerfile': ['hadolint'],
      \ 'markdown': ['markdownlint'],
      \ 'javascript': ['eslint'],
      \ 'typescript': ['eslint'],
      \ 'vim': ['vint'],
      \ 'nginx': ['nginx-linter'],
      \ }

let g:ale_fixers = {
      \ '*': ['remove_trailing_lines', 'trim_whitespace'],
      \ 'elixir': ['mix_format'],
      \ 'php': ['php_cs_fixer'],
      \ 'c': ['clang-format'],
      \ 'cpp': ['clang-format'],
      \ 'dart': ['dart-format'],
      \ 'sql': ['pgformatter'],
      \ 'erlang': ['erlfmt'],
      \ 'javascript': ['eslint', 'prettier'],
      \ 'typescript': ['eslint', 'prettier'],
      \ 'json': ['prettier'],
      \ 'markdown': ['prettier'],
      \ 'yaml': ['prettier'],
      \ 'css': ['prettier'],
      \ }

let g:ale_fix_on_save = 0  " Set to 1 to auto-fix on save
let g:ale_lint_on_text_changed = 'normal'
let g:ale_lint_on_insert_leave = 1

" ---- Elixir / Mix Format ----
let g:mix_format_on_save = 1
let g:mix_format_silent_errors = 1

" ---- PHP CS Fixer ----
let g:php_cs_fixer_rules = "@PSR12"
let g:php_cs_fixer_php_path = "php"

" ---- Clang Format (C/C++) ----
let g:clang_format#auto_format = 0
let g:clang_format#detect_style_file = 1

" ---- vim-dadbod (SQL) ----
" Define your database connections (add your actual connection strings)
" let g:dbs = {
"       \ 'mssql_dev': 'sqlserver://user:pass@host:1433/database',
"       \ 'postgres_dev': 'postgresql://user:pass@host:5432/database',
"       \ 'mysql_dev': 'mysql://user:pass@host:3306/database',
"       \ 'sqlite_dev': 'sqlite:path/to/database.db',
"       \ }
let g:db_ui_use_nerd_fonts = 1
let g:db_ui_show_database_icon = 1
let g:db_ui_auto_execute_table_helpers = 1

" Autocomplete for SQL via dadbod-completion
autocmd FileType sql,mysql,plsql lua function() end
autocmd FileType sql setlocal omnifunc=vim_dadbod_completion#omni

" ---- vim-flutter ----
let g:flutter_show_log_on_run = 'tab'
let g:flutter_autoscroll = 1
let g:dart_style_guide = 2

" ---- Tmux Navigator ----
let g:tmux_navigator_no_mappings = 1

" ---- vim-test ----
let test#strategy = "vimux"
let test#elixir#exunit#executable = 'mix test'
let test#php#phpunit#executable = 'vendor/bin/phpunit'

" ---- EasyMotion ----
let g:EasyMotion_smartcase = 1

" ---- IndentLine ----
let g:indentLine_char = '│'
let g:indentLine_enabled = 1

" ---- Signify ----
let g:signify_sign_add = '+'
let g:signify_sign_delete = '_'
let g:signify_sign_delete_first_line = '‾'
let g:signify_sign_change = '~'

" ---- vim-visual-multi ----
let g:VM_maps = {}
let g:VM_maps['Find Under'] = '<C-d>'
let g:VM_maps['Find Subword Under'] = '<C-d>'

" ---- FZF ----
let $FZF_DEFAULT_OPTS='--layout=reverse'
let $FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob "!.git/*" --glob "!node_modules/*" --glob "!_build/*" --glob "!deps/*"'

command! -bang -nargs=? -complete=dir GFiles
  \ call fzf#vim#gitfiles(<q-args>, fzf#vim#with_preview(), <bang>0)

command! -bang -nargs=* Ag
  \ call fzf#vim#ag(<q-args>, fzf#vim#with_preview(), <bang>0)

command! -bang -nargs=? -complete=dir Files
  \ call fzf#vim#files(<q-args>, fzf#vim#with_preview(), <bang>0)

" Use Rg (ripgrep) if available
if executable('rg')
  command! -bang -nargs=* Rg
    \ call fzf#vim#grep(
    \   'rg --column --line-number --no-heading --color=always --smart-case -- '.shellescape(<q-args>), 1,
    \   fzf#vim#with_preview(), <bang>0)
endif

" ---- Markdown ----
let g:vim_markdown_folding_disabled = 1
let g:vim_markdown_conceal = 0
let g:vim_markdown_conceal_code_blocks = 0
let g:vim_markdown_frontmatter = 1         " YAML front matter
let g:vim_markdown_toml_frontmatter = 1    " TOML front matter
let g:vim_markdown_fenced_languages = [
      \ 'elixir', 'php', 'c', 'cpp', 'dart',
      \ 'sql', 'javascript', 'js=javascript',
      \ 'typescript', 'ts=typescript',
      \ 'bash=sh', 'shell=sh', 'json',
      \ 'html', 'css', 'yaml', 'dockerfile',
      \ 'erlang', 'vim', 'nginx'
      \ ]

" ---- Markdown Preview ----
let g:mkdp_auto_start = 0
let g:mkdp_auto_close = 1
let g:mkdp_refresh_slow = 0
let g:mkdp_browser = ''

" ---- Nginx ----
autocmd BufRead,BufNewFile */nginx/*.conf set filetype=nginx
autocmd BufRead,BufNewFile */nginx/**/*.conf set filetype=nginx
autocmd BufRead,BufNewFile nginx.conf set filetype=nginx
autocmd BufRead,BufNewFile */sites-available/* set filetype=nginx
autocmd BufRead,BufNewFile */sites-enabled/* set filetype=nginx
autocmd BufRead,BufNewFile */conf.d/*.conf set filetype=nginx

" ---- Docker ----
autocmd BufRead,BufNewFile Dockerfile* set filetype=dockerfile
autocmd BufRead,BufNewFile docker-compose*.yml set filetype=yaml.docker-compose
autocmd BufRead,BufNewFile docker-compose*.yaml set filetype=yaml.docker-compose

" ---- EditorConfig ----
let g:EditorConfig_exclude_patterns = ['fugitive://.*']
