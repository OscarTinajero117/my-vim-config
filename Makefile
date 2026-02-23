# ============================================================================
# My Vim Config - Makefile
# Quick commands for managing the vim configuration
# ============================================================================

SHELL := /bin/bash
CONFIG_DIR := $(HOME)/.vim-config
VIM_DIR := $(HOME)/.vim

.PHONY: help install uninstall update tools link plug plugins backup

help: ## Show this help
	@echo ""
	@echo "My Vim Config - Available commands:"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'
	@echo ""

install: ## Full installation (backup + link + plug + plugins)
	@./install.sh

uninstall: ## Remove symlinks and restore backup
	@./install.sh --uninstall

update: ## Pull latest changes and update plugins
	@echo "==> Actualizando repositorio..."
	@git pull --rebase origin main
	@echo "==> Actualizando plugins..."
	@vim +PlugUpdate +qall 2>/dev/null || vim +PlugUpdate +qall
	@echo "==> ¡Actualización completada!"

link: ## Create symlinks only (no plugin install)
	@mkdir -p $(VIM_DIR)/colors $(VIM_DIR)/undodir
	@ln -sf $(PWD)/vimrc $(HOME)/.vimrc
	@ln -sf $(PWD)/vimrc.plug $(HOME)/.vimrc.plug
	@ln -sf $(PWD)/vim/maps.vim $(VIM_DIR)/maps.vim
	@ln -sf $(PWD)/vim/plugin-config.vim $(VIM_DIR)/plugin-config.vim
	@ln -sf $(PWD)/coc-settings.json $(VIM_DIR)/coc-settings.json
	@for f in $(PWD)/colors/*.vim; do ln -sf $$f $(VIM_DIR)/colors/$$(basename $$f); done
	@echo "Symlinks creados exitosamente"

plug: ## Install vim-plug
	@if [ ! -f $(VIM_DIR)/autoload/plug.vim ]; then \
		curl -fLo $(VIM_DIR)/autoload/plug.vim --create-dirs \
			https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim; \
		echo "vim-plug instalado"; \
	else \
		echo "vim-plug ya está instalado"; \
	fi

plugins: plug ## Install all Vim plugins
	@vim +PlugInstall +qall 2>/dev/null || vim +PlugInstall +qall
	@echo "Plugins instalados"

clean-plugins: ## Remove all installed plugins
	@vim +PlugClean! +qall 2>/dev/null || true
	@echo "Plugins limpiados"

backup: ## Backup current vim configuration
	@BACKUP_DIR=$(HOME)/.vim-backup-$$(date +%Y%m%d%H%M%S); \
	mkdir -p $$BACKUP_DIR; \
	[ -f $(HOME)/.vimrc ] && cp -L $(HOME)/.vimrc $$BACKUP_DIR/ || true; \
	[ -f $(HOME)/.vimrc.plug ] && cp -L $(HOME)/.vimrc.plug $$BACKUP_DIR/ || true; \
	[ -d $(VIM_DIR) ] && cp -rL $(VIM_DIR) $$BACKUP_DIR/vim || true; \
	echo "Backup creado en: $$BACKUP_DIR"

tools-essential: ## Install essential tools only (ripgrep, fzf, prettier)
	@echo "==> Instalando herramientas esenciales..."
	@if command -v brew &>/dev/null; then \
		brew install ripgrep fzf; \
	elif command -v apt-get &>/dev/null; then \
		sudo apt-get install -y ripgrep fzf; \
	elif command -v pacman &>/dev/null; then \
		sudo pacman -S --noconfirm ripgrep fzf; \
	elif command -v dnf &>/dev/null; then \
		sudo dnf install -y ripgrep fzf; \
	fi
	@npm install -g prettier eslint 2>/dev/null || true
	@echo "Herramientas esenciales instaladas"

tools: tools-essential ## Install all external tools
	@echo "==> Instalando todas las herramientas..."
	@npm install -g typescript ts-node markdownlint-cli sql-lint 2>/dev/null || true
	@if command -v pipx &>/dev/null; then \
		pipx install vim-vint 2>/dev/null || true; \
		pipx install gixy 2>/dev/null || true; \
	elif command -v pip3 &>/dev/null; then \
		pip3 install --user vim-vint gixy 2>/dev/null || true; \
	fi
	@if command -v composer &>/dev/null; then \
		composer global require --no-interaction squizlabs/php_codesniffer phpstan/phpstan friendsofphp/php-cs-fixer 2>/dev/null || true; \
	fi
	@if command -v brew &>/dev/null; then \
		brew install llvm pgformatter hadolint 2>/dev/null || true; \
	elif command -v apt-get &>/dev/null; then \
		sudo apt-get install -y clangd clang-format clang-tidy pgformatter 2>/dev/null || true; \
	fi
	@echo "Todas las herramientas instaladas"

check: ## Check which tools are installed
	@echo ""
	@echo "=== Estado de herramientas ==="
	@echo ""
	@for cmd in vim node npm git rg fzf prettier eslint tsc clangd \
		clang-format php composer hadolint markdownlint elixir mix dart flutter \
		erlc gixy pgformatter vint phpcs phpstan php-cs-fixer sql-lint; do \
		if command -v $$cmd &>/dev/null 2>&1; then \
			printf "  \033[32m✓\033[0m %-20s %s\n" "$$cmd" "$$($$cmd --version 2>/dev/null | head -1 || echo 'instalado')"; \
		else \
			printf "  \033[31m✗\033[0m %-20s %s\n" "$$cmd" "no encontrado"; \
		fi; \
	done
	@echo ""
