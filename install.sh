#!/usr/bin/env bash
# ============================================================================
# My Vim Config - Installer for macOS & Linux
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/OscarTinajero117/my-vim-config/main/install.sh | bash
#   or
#   git clone https://github.com/OscarTinajero117/my-vim-config.git && cd my-vim-config && ./install.sh
# ============================================================================

set -euo pipefail

# ---- Colors ----
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# ---- Helpers ----
info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[OK]${NC} $1"; }
warn()    { echo -e "${YELLOW}[WARN]${NC} $1"; }
error()   { echo -e "${RED}[ERROR]${NC} $1"; }
step()    { echo -e "\n${CYAN}==>${NC} ${1}"; }

command_exists() { command -v "$1" &>/dev/null; }

# Read user input from /dev/tty (works even when piped via curl | bash)
ask() {
  read -rp "$1" "$2" </dev/tty
}

# ---- Detect OS ----
detect_os() {
  case "$(uname -s)" in
    Darwin*) OS="macos" ;;
    Linux*)  OS="linux" ;;
    MINGW*|MSYS*|CYGWIN*) OS="windows" ;;
    *) error "Sistema operativo no soportado: $(uname -s)"; exit 1 ;;
  esac

  if [[ "$OS" == "linux" ]]; then
    if command_exists apt-get; then
      PKG_MANAGER="apt"
    elif command_exists dnf; then
      PKG_MANAGER="dnf"
    elif command_exists yum; then
      PKG_MANAGER="yum"
    elif command_exists pacman; then
      PKG_MANAGER="pacman"
    elif command_exists zypper; then
      PKG_MANAGER="zypper"
    else
      PKG_MANAGER="unknown"
    fi
  elif [[ "$OS" == "macos" ]]; then
    PKG_MANAGER="brew"
  fi

  info "Sistema detectado: ${OS} (${PKG_MANAGER})"
}

# ---- Package install helper ----
pkg_install() {
  local pkg="$1"
  local name="${2:-$pkg}"

  if command_exists "$pkg"; then
    success "$name ya está instalado"
    return 0
  fi

  info "Instalando $name..."
  case "$PKG_MANAGER" in
    brew)   brew install "$pkg" 2>/dev/null || warn "No se pudo instalar $name via brew" ;;
    apt)    sudo apt-get install -y "$pkg" 2>/dev/null || warn "No se pudo instalar $name via apt" ;;
    dnf)    sudo dnf install -y "$pkg" 2>/dev/null || warn "No se pudo instalar $name via dnf" ;;
    yum)    sudo yum install -y "$pkg" 2>/dev/null || warn "No se pudo instalar $name via yum" ;;
    pacman) sudo pacman -S --noconfirm "$pkg" 2>/dev/null || warn "No se pudo instalar $name via pacman" ;;
    zypper) sudo zypper install -y "$pkg" 2>/dev/null || warn "No se pudo instalar $name via zypper" ;;
    *)      warn "No se pudo instalar $name (gestor de paquetes desconocido)" ;;
  esac
}

npm_install() {
  local pkg="$1"
  if command_exists "$pkg" || npm list -g "$pkg" &>/dev/null; then
    success "$pkg (npm) ya está instalado"
    return 0
  fi
  info "Instalando $pkg via npm..."
  # Try without sudo first, then with sudo on Linux
  if npm install -g "$pkg" 2>/dev/null; then
    success "$pkg instalado via npm"
  elif [[ "$OS" != "macos" ]] && sudo npm install -g "$pkg" 2>/dev/null; then
    success "$pkg instalado via npm (sudo)"
  else
    warn "No se pudo instalar $pkg via npm. Intenta manualmente: sudo npm install -g $pkg"
  fi
}

pip_install() {
  local pkg="$1"
  if pip3 show "$pkg" &>/dev/null 2>&1; then
    success "$pkg (pip) ya está instalado"
    return 0
  fi
  info "Instalando $pkg via pip..."
  # Try pipx first (Python 3.11+ recommended), then pip with fallbacks
  if command_exists pipx; then
    pipx install "$pkg" 2>/dev/null && success "$pkg instalado via pipx" && return 0
  fi
  if pip3 install --user "$pkg" 2>/dev/null; then
    success "$pkg instalado via pip"
  elif pip3 install --user --break-system-packages "$pkg" 2>/dev/null; then
    success "$pkg instalado via pip (break-system-packages)"
  else
    warn "No se pudo instalar $pkg. Intenta: pipx install $pkg o sudo pip3 install $pkg"
  fi
}

# ---- Config directory ----
REPO_URL="https://github.com/OscarTinajero117/my-vim-config.git"
CONFIG_DIR="$HOME/.vim-config"
VIM_DIR="$HOME/.vim"
BACKUP_DIR="$HOME/.vim-backup-$(date +%Y%m%d%H%M%S)"

# ---- Main installation ----
main() {
  echo -e "${CYAN}"
  echo "╔══════════════════════════════════════════════════╗"
  echo "║          My Vim Config - Installer               ║"
  echo "║     macOS / Linux automatic setup                ║"
  echo "╚══════════════════════════════════════════════════╝"
  echo -e "${NC}"

  detect_os

  # ================================================================
  # STEP 1: Prerequisites
  # ================================================================
  step "1/8 - Verificando prerequisitos..."

  # Git
  if ! command_exists git; then
    error "Git no está instalado. Instálalo primero."
    exit 1
  fi
  success "Git encontrado"

  # Vim
  if ! command_exists vim; then
    info "Instalando Vim..."
    pkg_install vim "Vim"
  fi
  success "Vim encontrado: $(vim --version | head -1)"

  # Node.js (required for CoC)
  if ! command_exists node; then
    warn "Node.js no encontrado. Es necesario para CoC."
    if [[ "$OS" == "macos" ]]; then
      info "Instalando Node.js via brew..."
      brew install node
    else
      info "Instalando Node.js via NodeSource..."
      if command_exists apt-get; then
        curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
        sudo apt-get install -y nodejs
      else
        pkg_install nodejs "Node.js"
      fi
    fi
  fi
  success "Node.js encontrado: $(node --version)"

  # npm
  if ! command_exists npm; then
    error "npm no encontrado. Instala Node.js correctamente."
    exit 1
  fi
  success "npm encontrado: $(npm --version)"

  # ================================================================
  # STEP 2: Backup existing config
  # ================================================================
  step "2/8 - Respaldando configuración existente..."

  BACKUP_NEEDED=false
  for f in "$HOME/.vimrc" "$HOME/.vimrc.plug" "$VIM_DIR"; do
    if [[ -e "$f" && ! -L "$f" ]]; then
      BACKUP_NEEDED=true
      break
    fi
  done

  if [[ "$BACKUP_NEEDED" == true ]]; then
    mkdir -p "$BACKUP_DIR"
    [[ -f "$HOME/.vimrc" && ! -L "$HOME/.vimrc" ]] && mv "$HOME/.vimrc" "$BACKUP_DIR/" && info "Respaldado: .vimrc"
    [[ -f "$HOME/.vimrc.plug" && ! -L "$HOME/.vimrc.plug" ]] && mv "$HOME/.vimrc.plug" "$BACKUP_DIR/" && info "Respaldado: .vimrc.plug"
    [[ -d "$VIM_DIR" && ! -L "$VIM_DIR" ]] && mv "$VIM_DIR" "$BACKUP_DIR/vim" && info "Respaldado: .vim/"
    success "Backup creado en: $BACKUP_DIR"
  else
    success "No se necesita backup (config limpia o ya es symlink)"
  fi

  # ================================================================
  # STEP 3: Clone/update repository
  # ================================================================
  step "3/8 - Clonando/actualizando repositorio..."

  if [[ -d "$CONFIG_DIR" ]]; then
    info "Repositorio ya existe, actualizando..."
    cd "$CONFIG_DIR"
    git pull --rebase origin main 2>/dev/null || warn "No se pudo actualizar (cambios locales?)"
    cd - > /dev/null
  else
    # Check if we're running from inside the repo
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    if [[ -f "$SCRIPT_DIR/vimrc" && -f "$SCRIPT_DIR/vimrc.plug" ]]; then
      info "Ejecutando desde el repositorio clonado, copiando a $CONFIG_DIR..."
      cp -r "$SCRIPT_DIR" "$CONFIG_DIR"
    else
      git clone "$REPO_URL" "$CONFIG_DIR"
    fi
  fi
  success "Repositorio listo en: $CONFIG_DIR"

  # ================================================================
  # STEP 4: Create symlinks
  # ================================================================
  step "4/8 - Creando symlinks..."

  # Ensure .vim directory exists
  mkdir -p "$VIM_DIR"

  # Create symlinks
  ln -sf "$CONFIG_DIR/vimrc" "$HOME/.vimrc"
  success "Symlink: ~/.vimrc"

  ln -sf "$CONFIG_DIR/vimrc.plug" "$HOME/.vimrc.plug"
  success "Symlink: ~/.vimrc.plug"

  # vim subdirectories
  ln -sf "$CONFIG_DIR/vim/maps.vim" "$VIM_DIR/maps.vim"
  success "Symlink: ~/.vim/maps.vim"

  ln -sf "$CONFIG_DIR/vim/plugin-config.vim" "$VIM_DIR/plugin-config.vim"
  success "Symlink: ~/.vim/plugin-config.vim"

  ln -sf "$CONFIG_DIR/coc-settings.json" "$VIM_DIR/coc-settings.json"
  success "Symlink: ~/.vim/coc-settings.json"

  # Colors
  mkdir -p "$VIM_DIR/colors"
  if [[ -d "$CONFIG_DIR/colors" ]]; then
    for color_file in "$CONFIG_DIR/colors"/*.vim; do
      [[ -f "$color_file" ]] && ln -sf "$color_file" "$VIM_DIR/colors/$(basename "$color_file")"
    done
    success "Symlink: ~/.vim/colors/"
  fi

  # Undo directory
  mkdir -p "$VIM_DIR/undodir"
  success "Directorio de undo creado: ~/.vim/undodir"

  # ================================================================
  # STEP 5: Install vim-plug
  # ================================================================
  step "5/8 - Instalando vim-plug..."

  if [[ -f "$VIM_DIR/autoload/plug.vim" ]]; then
    success "vim-plug ya está instalado"
  else
    curl -fLo "$VIM_DIR/autoload/plug.vim" --create-dirs \
      https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    success "vim-plug instalado"
  fi

  # ================================================================
  # STEP 6: Install Vim plugins
  # ================================================================
  step "6/8 - Instalando plugins de Vim..."

  vim -es -u "$HOME/.vimrc" +PlugInstall +qall </dev/tty 2>/dev/null || \
    vim +PlugInstall +qall </dev/tty 2>/dev/null || \
    warn "No se pudieron instalar plugins automáticamente. Abre Vim y ejecuta :PlugInstall"

  success "Plugins instalados"

  # ================================================================
  # STEP 7: Install external tools
  # ================================================================
  step "7/8 - Instalando herramientas externas..."

  echo ""
  info "¿Deseas instalar las herramientas externas (linters, formatters, etc.)?"
  info "Puedes elegir qué categorías instalar."
  echo ""
  echo "  [1] Todas las herramientas (recomendado)"
  echo "  [2] Solo herramientas esenciales (ripgrep, fzf, prettier)"
  echo "  [3] Seleccionar manualmente"
  echo "  [4] Omitir (instalar después manualmente)"
  echo ""
  read -rp "Opción [1-4] (default: 1): " TOOLS_CHOICE </dev/tty
  TOOLS_CHOICE="${TOOLS_CHOICE:-1}"

  install_essentials() {
    pkg_install ripgrep "ripgrep"
    pkg_install fzf "fzf"
    npm_install prettier
    npm_install eslint
  }

  install_php_tools() {
    if command_exists composer; then
      info "Instalando herramientas PHP..."
      composer global require squizlabs/php_codesniffer 2>/dev/null || warn "phpcs no instalado"
      composer global require phpstan/phpstan 2>/dev/null || warn "phpstan no instalado"
      composer global require friendsofphp/php-cs-fixer 2>/dev/null || warn "php-cs-fixer no instalado"
      success "Herramientas PHP instaladas"
    else
      warn "Composer no encontrado. Instala Composer para herramientas PHP."
    fi
  }

  install_c_tools() {
    if [[ "$OS" == "macos" ]]; then
      pkg_install llvm "LLVM (clangd, clang-format)"
    else
      case "$PKG_MANAGER" in
        apt)    sudo apt-get install -y clangd clang-format clang-tidy 2>/dev/null || warn "No se instalaron herramientas C/C++" ;;
        dnf)    sudo dnf install -y clang-tools-extra 2>/dev/null || warn "No se instalaron herramientas C/C++" ;;
        pacman) sudo pacman -S --noconfirm clang 2>/dev/null || warn "No se instalaron herramientas C/C++" ;;
        *)      warn "Instala manualmente: clangd, clang-format, clang-tidy" ;;
      esac
    fi
    success "Herramientas C/C++ configuradas"
  }

  install_sql_tools() {
    if [[ "$OS" == "macos" ]]; then
      pkg_install pgformatter "pgformatter"
    else
      pkg_install pgformatter "pgformatter" 2>/dev/null || warn "pgformatter no disponible. Instálalo manualmente."
    fi
    npm_install sql-lint
    success "Herramientas SQL configuradas"
  }

  install_docker_tools() {
    if [[ "$OS" == "macos" ]]; then
      brew install hadolint 2>/dev/null || warn "hadolint no instalado"
    else
      # Try to install hadolint binary
      if ! command_exists hadolint; then
        info "Instalando hadolint..."
        local HADOLINT_URL="https://github.com/hadolint/hadolint/releases/latest/download/hadolint-Linux-x86_64"
        sudo curl -fsSL "$HADOLINT_URL" -o /usr/local/bin/hadolint 2>/dev/null && \
          sudo chmod +x /usr/local/bin/hadolint && \
          success "hadolint instalado" || \
          warn "No se pudo instalar hadolint. Instálalo manualmente."
      fi
    fi
  }

  install_node_tools() {
    npm_install typescript
    npm_install ts-node
    npm_install markdownlint-cli
    npm_install sql-lint
    success "Herramientas Node.js instaladas"
  }

  install_python_tools() {
    pip_install vim-vint
    pip_install nginx-linter
    success "Herramientas Python instaladas"
  }

  case "$TOOLS_CHOICE" in
    1)
      install_essentials
      install_php_tools
      install_c_tools
      install_sql_tools
      install_docker_tools
      install_node_tools
      install_python_tools
      ;;
    2)
      install_essentials
      ;;
    3)
      install_essentials
      echo ""
      read -rp "¿Instalar herramientas PHP? [y/N]: " yn </dev/tty
      [[ "$yn" =~ ^[Yy]$ ]] && install_php_tools

      read -rp "¿Instalar herramientas C/C++? [y/N]: " yn </dev/tty
      [[ "$yn" =~ ^[Yy]$ ]] && install_c_tools

      read -rp "¿Instalar herramientas SQL? [y/N]: " yn </dev/tty
      [[ "$yn" =~ ^[Yy]$ ]] && install_sql_tools

      read -rp "¿Instalar herramientas Docker? [y/N]: " yn </dev/tty
      [[ "$yn" =~ ^[Yy]$ ]] && install_docker_tools

      read -rp "¿Instalar herramientas Node.js? [y/N]: " yn </dev/tty
      [[ "$yn" =~ ^[Yy]$ ]] && install_node_tools

      read -rp "¿Instalar herramientas Python (vint, nginx-linter)? [y/N]: " yn </dev/tty
      [[ "$yn" =~ ^[Yy]$ ]] && install_python_tools
      ;;
    4)
      info "Omitiendo instalación de herramientas externas"
      ;;
  esac

  # ================================================================
  # STEP 8: Done!
  # ================================================================
  step "8/8 - ¡Instalación completada!"

  echo ""
  echo -e "${GREEN}╔══════════════════════════════════════════════════╗${NC}"
  echo -e "${GREEN}║          ¡Instalación exitosa!                   ║${NC}"
  echo -e "${GREEN}╚══════════════════════════════════════════════════╝${NC}"
  echo ""
  info "Config dir:     $CONFIG_DIR"
  info "Symlinks:       ~/.vimrc, ~/.vimrc.plug, ~/.vim/"
  [[ "$BACKUP_NEEDED" == true ]] && info "Backup:         $BACKUP_DIR"
  echo ""
  info "Próximos pasos:"
  echo "  1. Abre Vim y espera que CoC instale las extensiones"
  echo "  2. Ejecuta :CocInfo dentro de Vim para verificar que todo funciona"
  echo "  3. (Opcional) Si usas bases de datos, edita ~/.vim/plugin-config.vim"
  echo "     y descomenta la sección 'g:dbs' con tus datos de conexión."
  echo "     Ejemplo: 'postgresql://usuario:password@localhost:5432/mi_db'"
  echo ""
  info "Para actualizar la config en el futuro:"
  echo "  cd $CONFIG_DIR && git pull"
  echo ""
  info "Para desinstalar:"
  echo "  ./install.sh --uninstall"
  echo ""
}

# ---- Uninstall ----
uninstall() {
  step "Desinstalando My Vim Config..."

  echo ""
  warn "Esto eliminará los symlinks creados por el instalador."
  read -rp "¿Continuar? [y/N]: " yn </dev/tty
  [[ ! "$yn" =~ ^[Yy]$ ]] && { info "Cancelado."; exit 0; }

  # Remove symlinks (only if they point to our config)
  for f in "$HOME/.vimrc" "$HOME/.vimrc.plug"; do
    if [[ -L "$f" ]]; then
      rm "$f"
      info "Eliminado symlink: $f"
    fi
  done

  for f in "$VIM_DIR/maps.vim" "$VIM_DIR/plugin-config.vim" "$VIM_DIR/coc-settings.json"; do
    if [[ -L "$f" ]]; then
      rm "$f"
      info "Eliminado symlink: $f"
    fi
  done

  if [[ -d "$VIM_DIR/colors" ]]; then
    for f in "$VIM_DIR/colors"/*.vim; do
      if [[ -L "$f" ]]; then
        rm "$f"
        info "Eliminado symlink: $f"
      fi
    done
  fi

  echo ""
  info "Symlinks eliminados. El repositorio en $CONFIG_DIR NO fue eliminado."
  info "Para eliminarlo completamente: rm -rf $CONFIG_DIR"

  # Restore backup if exists
  LATEST_BACKUP=$(ls -dt "$HOME"/.vim-backup-* 2>/dev/null | head -1)
  if [[ -n "$LATEST_BACKUP" ]]; then
    echo ""
    read -rp "¿Restaurar backup desde $LATEST_BACKUP? [y/N]: " yn </dev/tty
    if [[ "$yn" =~ ^[Yy]$ ]]; then
      [[ -f "$LATEST_BACKUP/.vimrc" ]] && mv "$LATEST_BACKUP/.vimrc" "$HOME/.vimrc"
      [[ -f "$LATEST_BACKUP/.vimrc.plug" ]] && mv "$LATEST_BACKUP/.vimrc.plug" "$HOME/.vimrc.plug"
      [[ -d "$LATEST_BACKUP/vim" ]] && mv "$LATEST_BACKUP/vim" "$VIM_DIR"
      success "Backup restaurado"
    fi
  fi

  success "Desinstalación completada"
}

# ---- Entry point ----
case "${1:-}" in
  --uninstall|-u) uninstall ;;
  --help|-h)
    echo "Uso: $0 [opción]"
    echo ""
    echo "Opciones:"
    echo "  (sin opción)    Instalar la configuración de Vim"
    echo "  --uninstall     Desinstalar y restaurar backup"
    echo "  --help          Mostrar esta ayuda"
    ;;
  *) main ;;
esac
