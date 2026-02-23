# My Vim Config

Configuración personalizada de Vim optimizada para desarrollo con múltiples lenguajes y frameworks.

## Lenguajes y tecnologías soportadas

| Lenguaje / Tecnología | LSP (CoC) | Linting (ALE) | Formato | Snippets |
|----------------------|-----------|---------------|---------|----------|
| **Elixir / Phoenix** | coc-elixir (ElixirLS) | credo, dialyxir | mix format | ✅ |
| **Erlang** | erlang_ls | erlc, dialyzer | erlfmt | ✅ |
| **PHP** | coc-phpls (Intelephense) | php, phpcs, phpstan | php-cs-fixer (PSR-12) | ✅ |
| **Dart / Flutter** | coc-flutter | dart_analyze | dart-format | ✅ |
| **C / C++** | coc-clangd | cc, clangtidy | clang-format | ✅ |
| **SQL** | coc-sql | sqlint | pgformatter | ✅ |
| **JavaScript / Node.js** | coc-tsserver | eslint | prettier | ✅ |
| **TypeScript** | coc-tsserver | eslint | prettier | ✅ |
| **Nginx** | — | gixy | — | ✅ |
| **Docker** | coc-docker | hadolint | — | ✅ |
| **Markdown** | coc-markdownlint | markdownlint | prettier | ✅ |
| **Vim script** | coc-vimlsp | vint | — | ✅ |
| **HTML / CSS** | coc-html, coc-css | — | prettier | ✅ |
| **JSON / YAML** | coc-json, coc-yaml | — | prettier | ✅ |

## Estructura del proyecto

```
.
├── vimrc                  # Configuración principal de Vim
├── vimrc.plug             # Definición de plugins (vim-plug)
├── coc-settings.json      # Configuración de CoC (LSP)
├── install.sh             # Instalador automático (macOS/Linux)
├── install.ps1            # Instalador automático (Windows)
├── Makefile               # Comandos rápidos (make install, make update...)
├── vim/
│   ├── maps.vim           # Keybindings y mappings
│   └── plugin-config.vim  # Configuración individual de plugins
├── colors/
│   └── molokai.vim        # Tema Molokai
├── README.md
└── LICENSE
```

## Requisitos previos

- **Vim 8.2+** (con soporte para `+python3`, `+terminal`)
- **Node.js 16+** (requerido por CoC)
- **Git**
- **macOS**: Homebrew recomendado
- **Linux**: apt, dnf, pacman o zypper
- **Windows**: Scoop, Chocolatey o Winget recomendado

## Instalación rápida (un solo comando)

### macOS / Linux

```bash
# Opción 1: Clonar e instalar
git clone https://github.com/OscarTinajero117/my-vim-config.git && cd my-vim-config && ./install.sh

# Opción 2: Instalación directa (sin clonar manualmente)
curl -fsSL https://raw.githubusercontent.com/OscarTinajero117/my-vim-config/main/install.sh | bash
```

### Windows (PowerShell)

```powershell
# Clonar e instalar
git clone https://github.com/OscarTinajero117/my-vim-config.git; cd my-vim-config; .\install.ps1

# Si no puedes ejecutar scripts, primero habilita la ejecución:
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Usando Make (macOS / Linux)

```bash
git clone https://github.com/OscarTinajero117/my-vim-config.git
cd my-vim-config

make install          # Instalación completa
make link             # Solo crear symlinks
make plugins          # Solo instalar plugins
make tools            # Solo instalar herramientas externas
make tools-essential  # Solo ripgrep, fzf, prettier, eslint
make update           # Actualizar config + plugins
make check            # Verificar qué herramientas están instaladas
make uninstall        # Desinstalar
make help             # Ver todos los comandos
```

## ¿Qué hace el instalador?

El script de instalación realiza automáticamente:

1. **Detecta tu OS** (macOS, Linux, Windows) y gestor de paquetes
2. **Verifica prerequisitos** (git, vim, node)
3. **Respalda** tu configuración existente en `~/.vim-backup-TIMESTAMP/`
4. **Clona** el repositorio en `~/.vim-config/`
5. **Crea symlinks** a `~/.vimrc`, `~/.vimrc.plug`, `~/.vim/`
6. **Instala vim-plug** si no existe
7. **Instala plugins** automáticamente
8. **Opcionalmente instala** herramientas externas (linters, formatters, LSPs)

### Desinstalación

```bash
# macOS / Linux
./install.sh --uninstall

# Windows
.\install.ps1 -Uninstall

# Make
make uninstall
```

La desinstalación elimina los symlinks y ofrece restaurar tu backup anterior.

## Instalación manual (paso a paso)

Si prefieres no usar el instalador automático:

```bash
# 1. Clonar el repositorio
git clone https://github.com/OscarTinajero117/my-vim-config.git
cd my-vim-config

# 2. Instalar vim-plug
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# 3. Crear symlinks
mkdir -p ~/.vim/colors ~/.vim/undodir
ln -sf $(pwd)/vimrc ~/.vimrc
ln -sf $(pwd)/vimrc.plug ~/.vimrc.plug
ln -sf $(pwd)/vim/maps.vim ~/.vim/maps.vim
ln -sf $(pwd)/vim/plugin-config.vim ~/.vim/plugin-config.vim
ln -sf $(pwd)/coc-settings.json ~/.vim/coc-settings.json
ln -sf $(pwd)/colors/molokai.vim ~/.vim/colors/molokai.vim

# 4. Instalar plugins
vim +PlugInstall +qall

# 5. Las extensiones de CoC se instalan automáticamente al abrir Vim
```

En **Windows** (PowerShell, crear como copia si no tienes permisos de admin):

```powershell
# Clonar
git clone https://github.com/OscarTinajero117/my-vim-config.git
cd my-vim-config

# Crear directorios
New-Item -ItemType Directory -Path "$env:USERPROFILE\vimfiles\autoload" -Force
New-Item -ItemType Directory -Path "$env:USERPROFILE\vimfiles\colors" -Force
New-Item -ItemType Directory -Path "$env:USERPROFILE\vimfiles\undodir" -Force

# Descargar vim-plug
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim" `
    -OutFile "$env:USERPROFILE\vimfiles\autoload\plug.vim"

# Copiar archivos
Copy-Item vimrc "$env:USERPROFILE\_vimrc" -Force
Copy-Item vimrc.plug "$env:USERPROFILE\.vimrc.plug" -Force
Copy-Item vim\maps.vim "$env:USERPROFILE\vimfiles\maps.vim" -Force
Copy-Item vim\plugin-config.vim "$env:USERPROFILE\vimfiles\plugin-config.vim" -Force
Copy-Item coc-settings.json "$env:USERPROFILE\vimfiles\coc-settings.json" -Force
Copy-Item colors\molokai.vim "$env:USERPROFILE\vimfiles\colors\molokai.vim" -Force

# Instalar plugins
vim +PlugInstall +qall
```

## Dependencias externas (por lenguaje)

### Elixir / Phoenix / Erlang

```bash
# ElixirLS se instala automáticamente via coc-elixir
# Herramientas de linting
mix archive.install hex credo
mix archive.install hex dialyxir

# Erlang Language Server
# https://github.com/erlang-ls/erlang_ls
```

### PHP

```bash
# Intelephense se instala automáticamente via coc-phpls
composer global require squizlabs/php_codesniffer
composer global require phpstan/phpstan
composer global require friendsofphp/php-cs-fixer
```

### C / C++

```bash
# macOS
brew install llvm          # Incluye clangd y clang-format

# Linux (Debian/Ubuntu)
sudo apt install clangd clang-format clang-tidy
```

### Dart / Flutter

```bash
# Flutter SDK incluye dart y el language server
# https://docs.flutter.dev/get-started/install
```

### SQL

```bash
# Formateador (PostgreSQL)
brew install pgformatter   # macOS
# o
sudo apt install pgformatter  # Linux

# Linter
npm install -g sql-lint
```

### Nginx

```bash
# Linter/analizador de seguridad para configuraciones Nginx
pipx install gixy       # Python 3.11+ (recomendado)
# o
pip3 install --user gixy

# Verificar sintaxis con nginx directamente
# nginx -t -c /path/to/nginx.conf
```

### Docker

```bash
# Linter para Dockerfiles
brew install hadolint      # macOS
# o
sudo apt install hadolint  # Linux
```

### Node.js / JavaScript / TypeScript

```bash
npm install -g eslint prettier typescript ts-node
```

### Markdown

```bash
npm install -g markdownlint-cli
```

### Vim script

```bash
pipx install vim-vint    # Python 3.11+ (recomendado)
# o
pip3 install --user vim-vint
```

### Herramientas generales recomendadas

```bash
# Búsqueda rápida (usado por :Rg en FZF)
brew install ripgrep

# Fuzzy finder
brew install fzf

# Gestor de versiones de Node (recomendado)
brew install nvm
```

## Keybindings

**Leader key: `<Space>`**

### General

| Atajo | Acción |
|-------|--------|
| `<Leader>w` | Guardar archivo |
| `<Leader>q` | Cerrar ventana |
| `<Leader>Q` | Cerrar sin guardar |
| `<Leader>;` | Agregar `;` al final de línea |
| `<Leader><Space>` | Limpiar resaltado de búsqueda |
| `jk` / `kj` | Escape rápido (modo insert) |
| `K` | Mostrar documentación (hover) |

### Navegación de código (CoC)

| Atajo | Acción |
|-------|--------|
| `gd` | Ir a definición |
| `gy` | Ir a type definition |
| `gi` | Ir a implementación |
| `gr` | Ver referencias |
| `<Leader>rn` | Renombrar símbolo |
| `<Leader>ca` | Code actions |
| `<Leader>cf` | Quick fix |
| `<Leader>f` | Formatear selección |
| `[d` / `]d` | Diagnóstico anterior / siguiente |
| `<Ctrl-Space>` | Trigger autocompletado |

### Linting (ALE)

| Atajo | Acción |
|-------|--------|
| `<Leader>af` | Aplicar fix (ALE) |
| `<Leader>al` | Ejecutar lint manualmente |
| `[a` / `]a` | Error anterior / siguiente |

### Archivos y búsqueda

| Atajo | Acción |
|-------|--------|
| `<Leader>nt` | NERDTree (buscar archivo actual) |
| `<Leader>p` | Buscar archivos (FZF) |
| `<Leader>ag` | Buscar texto (Ag) |
| `<Leader>rg` | Buscar texto (Ripgrep) |
| `<Leader>gf` | Buscar en archivos Git |
| `<Leader>ob` | Listar buffers |
| `<Leader>P` | Copiar path relativo |
| `<Leader>PP` | Copiar path absoluto |

### Tabs y buffers

| Atajo | Acción |
|-------|--------|
| `<Leader>h` | Tab anterior |
| `<Leader>l` | Tab siguiente |
| `<Leader>tn` | Nuevo tab |
| `<Leader>tc` | Cerrar tab |
| `<Leader>bn` | Buffer siguiente |
| `<Leader>bp` | Buffer anterior |
| `<Leader>bd` | Cerrar buffer |

### Git (Fugitive)

| Atajo | Acción |
|-------|--------|
| `<Leader>G` | Git status |
| `<Leader>gp` | Git push |
| `<Leader>gl` | Git pull |
| `<Leader>gb` | Git blame |
| `<Leader>gd` | Git diff (split) |
| `<Leader>gs` | Git log (últimos 20 commits) |

### Flutter

| Atajo | Acción |
|-------|--------|
| `<Leader>fr` | Flutter run |
| `<Leader>fq` | Flutter quit |
| `<Leader>fh` | Hot reload |
| `<Leader>fR` | Hot restart |
| `<Leader>fD` | Visual debug |

### Elixir / Phoenix

| Atajo | Acción |
|-------|--------|
| `<Leader>mf` | mix format (archivo actual) |
| `<Leader>mt` | mix test (archivo actual) |
| `<Leader>mc` | mix compile |
| `<Leader>ms` | mix phx.server |

### Docker

| Atajo | Acción |
|-------|--------|
| `<Leader>dc` | docker compose up -d |
| `<Leader>dd` | docker compose down |
| `<Leader>dl` | docker compose logs (follow) |
| `<Leader>dp` | docker ps |
| `<Leader>db` | docker compose build |

### SQL (vim-dadbod)

| Atajo | Acción |
|-------|--------|
| `<Leader>du` | Toggle UI de base de datos |
| `<Leader>df` | Buscar buffer de BD |

### PHP Refactoring

| Atajo | Acción |
|-------|--------|
| `<Leader>rlv` | Renombrar variable local |
| `<Leader>rcv` | Renombrar variable de clase |
| `<Leader>rm` | Renombrar método |
| `<Leader>eu` | Extraer use |
| `<Leader>ec` | Extraer constante (visual) |
| `<Leader>ep` | Extraer propiedad de clase |
| `<Leader>np` | Crear propiedad |
| `<Leader>pdu` | Detectar use no utilizados |
| `<Leader>sg` | Crear setters/getters (visual) |
| `<Leader>da` | Documentar todo |

### Markdown

| Atajo | Acción |
|-------|--------|
| `<Leader>mp` | Preview en navegador |
| `<Leader>mP` | Detener preview |

### Movimiento y edición

| Atajo | Acción |
|-------|--------|
| `<Leader>s` | EasyMotion (2 chars) |
| `<Ctrl-d>` | Multi-cursor (seleccionar palabra) |
| `J` (visual) | Mover línea abajo |
| `K` (visual) | Mover línea arriba |
| `<Leader>j` | Mover línea abajo (normal) |
| `<Leader>k` | Mover línea arriba (normal) |
| `<Ctrl-j>` | Scroll rápido abajo |
| `<Ctrl-k>` | Scroll rápido arriba |
| `gc` | Comentar/descomentar (commentary) |

### Splits y terminal

| Atajo | Acción |
|-------|--------|
| `<Leader>>` | Agrandar split |
| `<Leader><` | Reducir split |
| `<Ctrl-t>` | Toggle terminal |
| `<Leader>x` | Ejecutar archivo (auto-detecta lenguaje) |

### Testing

| Atajo | Acción |
|-------|--------|
| `<Leader>t` | Test más cercano |
| `<Leader>T` | Test del archivo |
| `<Leader>TT` | Test suite completa |

## Conexiones de base de datos (vim-dadbod)

Para conectarte a tus bases de datos, descomenta y edita en `vim/plugin-config.vim`:

```vim
let g:dbs = {
      \ 'mssql_dev': 'sqlserver://user:pass@host:1433/database',
      \ 'postgres_dev': 'postgresql://user:pass@host:5432/database',
      \ 'mysql_dev': 'mysql://user:pass@host:3306/database',
      \ 'sqlite_dev': 'sqlite:path/to/database.db',
      \ }
```

Luego usa `<Leader>du` para abrir la UI de base de datos.

## Tema

El tema por defecto es **Molokai**. Para cambiar a **Gruvbox**, edita `vimrc`:

```vim
" Comentar la línea de molokai
"colorscheme molokai

" Descomentar gruvbox
colorscheme gruvbox
let g:gruvbox_contrast_dark="hard"
```

## Indentación por lenguaje

| Lenguaje | Espacios |
|----------|----------|
| Elixir, Dart, HTML, CSS, JS, SQL, Markdown, Vim | 2 |
| PHP, C, C++, Docker, Nginx | 4 |

## Solución de problemas

### CoC no instala extensiones

```bash
# Verificar que Node.js está instalado
node --version

# Reinstalar extensiones manualmente dentro de Vim
:CocInstall coc-elixir coc-phpls coc-clangd coc-flutter
```

### ALE no muestra errores

```bash
# Verificar que los linters están instalados
:ALEInfo
```

### FZF no encuentra archivos

```bash
# Instalar ripgrep para mejor rendimiento
brew install ripgrep
```

## Licencia

Ver [LICENSE](LICENSE).
