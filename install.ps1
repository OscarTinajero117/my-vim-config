# ============================================================================
# My Vim Config - Installer for Windows (PowerShell)
# Usage:
#   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
#   .\install.ps1
#
# Or one-liner (clone + install):
#   git clone https://github.com/OscarTinajero117/my-vim-config.git; cd my-vim-config; .\install.ps1
# ============================================================================

param(
    [switch]$Uninstall,
    [switch]$Help,
    [switch]$SkipTools
)

$ErrorActionPreference = "Continue"

# ---- Colors / Helpers ----
function Write-Info    { param($msg) Write-Host "[INFO] " -ForegroundColor Blue -NoNewline; Write-Host $msg }
function Write-Success { param($msg) Write-Host "[OK] " -ForegroundColor Green -NoNewline; Write-Host $msg }
function Write-Warn    { param($msg) Write-Host "[WARN] " -ForegroundColor Yellow -NoNewline; Write-Host $msg }
function Write-Err     { param($msg) Write-Host "[ERROR] " -ForegroundColor Red -NoNewline; Write-Host $msg }
function Write-Step    { param($msg) Write-Host "`n==> " -ForegroundColor Cyan -NoNewline; Write-Host $msg }

function Test-Command { param($cmd) return [bool](Get-Command $cmd -ErrorAction SilentlyContinue) }

# ---- Configuration ----
$RepoUrl = "https://github.com/OscarTinajero117/my-vim-config.git"
$ConfigDir = "$env:USERPROFILE\.vim-config"
$VimDir = "$env:USERPROFILE\vimfiles"       # Windows Vim uses ~/vimfiles
$VimRC = "$env:USERPROFILE\_vimrc"           # Windows Vim uses ~/_vimrc
$BackupDir = "$env:USERPROFILE\.vim-backup-$(Get-Date -Format 'yyyyMMddHHmmss')"

# Also support ~/.vim and ~/.vimrc for Git Bash / WSL compatibility
$VimDirAlt = "$env:USERPROFILE\.vim"
$VimRCAlt = "$env:USERPROFILE\.vimrc"

# ---- Help ----
if ($Help) {
    Write-Host @"

My Vim Config - Windows Installer

Usage:
    .\install.ps1               Install configuration
    .\install.ps1 -Uninstall    Remove symlinks and restore backup
    .\install.ps1 -SkipTools    Install config without external tools
    .\install.ps1 -Help         Show this help

"@
    exit 0
}

# ---- Uninstall ----
if ($Uninstall) {
    Write-Step "Desinstalando My Vim Config..."

    $confirm = Read-Host "Esto eliminará los symlinks creados. ¿Continuar? [y/N]"
    if ($confirm -ne "y" -and $confirm -ne "Y") {
        Write-Info "Cancelado."
        exit 0
    }

    # Remove symlinks
    foreach ($path in @($VimRC, $VimRCAlt, "$env:USERPROFILE\.vimrc.plug")) {
        if (Test-Path $path) {
            $item = Get-Item $path -Force
            if ($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) {
                Remove-Item $path -Force
                Write-Info "Eliminado symlink: $path"
            }
        }
    }

    foreach ($path in @("$VimDir\maps.vim", "$VimDir\plugin-config.vim", "$VimDir\coc-settings.json",
                        "$VimDirAlt\maps.vim", "$VimDirAlt\plugin-config.vim", "$VimDirAlt\coc-settings.json")) {
        if (Test-Path $path) {
            $item = Get-Item $path -Force
            if ($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) {
                Remove-Item $path -Force
                Write-Info "Eliminado symlink: $path"
            }
        }
    }

    # Restore backup
    $latestBackup = Get-ChildItem "$env:USERPROFILE\.vim-backup-*" -Directory -ErrorAction SilentlyContinue | Sort-Object Name -Descending | Select-Object -First 1
    if ($latestBackup) {
        $restore = Read-Host "¿Restaurar backup desde $($latestBackup.FullName)? [y/N]"
        if ($restore -eq "y" -or $restore -eq "Y") {
            if (Test-Path "$($latestBackup.FullName)\_vimrc") { Move-Item "$($latestBackup.FullName)\_vimrc" $VimRC }
            if (Test-Path "$($latestBackup.FullName)\vimfiles") { Move-Item "$($latestBackup.FullName)\vimfiles" $VimDir }
            Write-Success "Backup restaurado"
        }
    }

    Write-Success "Desinstalación completada"
    exit 0
}

# ============================================================================
# MAIN INSTALLATION
# ============================================================================

Write-Host ""
Write-Host "╔══════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║       My Vim Config - Windows Installer          ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# ================================================================
# STEP 1: Check if running as admin (needed for symlinks on older Windows)
# ================================================================
Write-Step "1/8 - Verificando permisos..."

$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator
)

# Check if Developer Mode is enabled (allows symlinks without admin)
$devMode = $false
try {
    $regPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock"
    $devMode = (Get-ItemProperty -Path $regPath -ErrorAction SilentlyContinue).AllowDevelopmentWithoutDevLicense -eq 1
} catch {}

if (-not $isAdmin -and -not $devMode) {
    Write-Warn "No tienes permisos de administrador ni Developer Mode activado."
    Write-Warn "Los symlinks se crearán como copias. Para symlinks reales:"
    Write-Info "  - Activa Developer Mode en Settings > For Developers"
    Write-Info "  - O ejecuta PowerShell como Administrador"
    $useSymlinks = $false
} else {
    $useSymlinks = $true
    Write-Success "Permisos suficientes para symlinks"
}

# ================================================================
# STEP 2: Prerequisites
# ================================================================
Write-Step "2/8 - Verificando prerequisitos..."

# Check for package manager (scoop or chocolatey or winget)
$pkgManager = "none"
if (Test-Command "scoop") { $pkgManager = "scoop" }
elseif (Test-Command "choco") { $pkgManager = "choco" }
elseif (Test-Command "winget") { $pkgManager = "winget" }

if ($pkgManager -eq "none") {
    Write-Warn "No se encontró gestor de paquetes (scoop/choco/winget)."
    Write-Info "Se recomienda instalar Scoop:"
    Write-Info '  irm get.scoop.sh | iex'
}
Write-Info "Gestor de paquetes: $pkgManager"

# Git
if (-not (Test-Command "git")) {
    Write-Err "Git no está instalado. Instálalo desde https://git-scm.com/download/win"
    exit 1
}
Write-Success "Git encontrado"

# Vim
if (-not (Test-Command "vim") -and -not (Test-Command "gvim")) {
    Write-Warn "Vim no encontrado. Intentando instalar..."
    switch ($pkgManager) {
        "scoop"  { scoop install vim }
        "choco"  { choco install vim -y }
        "winget" { winget install vim.vim }
        default  {
            Write-Err "Instala Vim manualmente desde https://www.vim.org/download.php"
            exit 1
        }
    }
}
Write-Success "Vim encontrado"

# Node.js
if (-not (Test-Command "node")) {
    Write-Warn "Node.js no encontrado. Intentando instalar..."
    switch ($pkgManager) {
        "scoop"  { scoop install nodejs-lts }
        "choco"  { choco install nodejs-lts -y }
        "winget" { winget install OpenJS.NodeJS.LTS }
        default  {
            Write-Err "Instala Node.js desde https://nodejs.org/"
            exit 1
        }
    }
}
Write-Success "Node.js encontrado: $(node --version)"

# ================================================================
# STEP 3: Backup existing config
# ================================================================
Write-Step "3/8 - Respaldando configuración existente..."

$backupNeeded = $false
foreach ($path in @($VimRC, $VimRCAlt, $VimDir, $VimDirAlt)) {
    if ((Test-Path $path) -and -not ((Get-Item $path -Force).Attributes -band [System.IO.FileAttributes]::ReparsePoint)) {
        $backupNeeded = $true
        break
    }
}

if ($backupNeeded) {
    New-Item -ItemType Directory -Path $BackupDir -Force | Out-Null

    foreach ($item in @(@{src=$VimRC; dst="_vimrc"}, @{src=$VimRCAlt; dst=".vimrc"}, @{src="$env:USERPROFILE\.vimrc.plug"; dst=".vimrc.plug"})) {
        if ((Test-Path $item.src) -and -not ((Get-Item $item.src -Force).Attributes -band [System.IO.FileAttributes]::ReparsePoint)) {
            Move-Item $item.src "$BackupDir\$($item.dst)" -Force
            Write-Info "Respaldado: $($item.dst)"
        }
    }

    foreach ($dir in @($VimDir, $VimDirAlt)) {
        if ((Test-Path $dir) -and -not ((Get-Item $dir -Force).Attributes -band [System.IO.FileAttributes]::ReparsePoint)) {
            Move-Item $dir "$BackupDir\$(Split-Path $dir -Leaf)" -Force
            Write-Info "Respaldado: $(Split-Path $dir -Leaf)\"
        }
    }

    Write-Success "Backup creado en: $BackupDir"
} else {
    Write-Success "No se necesita backup"
}

# ================================================================
# STEP 4: Clone/update repository
# ================================================================
Write-Step "4/8 - Clonando/actualizando repositorio..."

if (Test-Path $ConfigDir) {
    Write-Info "Repositorio ya existe, actualizando..."
    Push-Location $ConfigDir
    git pull --rebase origin main 2>$null
    Pop-Location
} else {
    # Check if running from cloned repo
    $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
    if ((Test-Path "$scriptDir\vimrc") -and (Test-Path "$scriptDir\vimrc.plug")) {
        Write-Info "Ejecutando desde el repositorio, copiando a $ConfigDir..."
        Copy-Item $scriptDir $ConfigDir -Recurse -Force
    } else {
        git clone $RepoUrl $ConfigDir
    }
}
Write-Success "Repositorio listo en: $ConfigDir"

# ================================================================
# STEP 5: Create symlinks (or copies)
# ================================================================
Write-Step "5/8 - Creando enlaces..."

function New-Link {
    param($Target, $Link)

    # Remove existing
    if (Test-Path $Link) { Remove-Item $Link -Force -Recurse }

    if ($useSymlinks) {
        if (Test-Path $Target -PathType Container) {
            New-Item -ItemType SymbolicLink -Path $Link -Target $Target -Force | Out-Null
        } else {
            New-Item -ItemType SymbolicLink -Path $Link -Target $Target -Force | Out-Null
        }
    } else {
        if (Test-Path $Target -PathType Container) {
            Copy-Item $Target $Link -Recurse -Force
        } else {
            Copy-Item $Target $Link -Force
        }
    }
    Write-Success "Link: $Link"
}

# Ensure vim directories exist
New-Item -ItemType Directory -Path $VimDir -Force | Out-Null
New-Item -ItemType Directory -Path $VimDirAlt -Force | Out-Null

# Main vimrc (both _vimrc for native Windows Vim and .vimrc for Git Bash)
New-Link "$ConfigDir\vimrc" $VimRC
New-Link "$ConfigDir\vimrc" $VimRCAlt

# vimrc.plug
New-Link "$ConfigDir\vimrc.plug" "$env:USERPROFILE\.vimrc.plug"

# Plugin configs (into both vimfiles and .vim for compatibility)
foreach ($vdir in @($VimDir, $VimDirAlt)) {
    New-Link "$ConfigDir\vim\maps.vim" "$vdir\maps.vim"
    New-Link "$ConfigDir\vim\plugin-config.vim" "$vdir\plugin-config.vim"
    New-Link "$ConfigDir\coc-settings.json" "$vdir\coc-settings.json"

    # Colors
    New-Item -ItemType Directory -Path "$vdir\colors" -Force | Out-Null
    Get-ChildItem "$ConfigDir\colors\*.vim" -ErrorAction SilentlyContinue | ForEach-Object {
        New-Link $_.FullName "$vdir\colors\$($_.Name)"
    }

    # Undo directory
    New-Item -ItemType Directory -Path "$vdir\undodir" -Force | Out-Null
}

Write-Success "Enlaces creados"

# ================================================================
# STEP 6: Install vim-plug
# ================================================================
Write-Step "6/8 - Instalando vim-plug..."

$plugPath = "$VimDir\autoload\plug.vim"
$plugPathAlt = "$VimDirAlt\autoload\plug.vim"

if (-not (Test-Path $plugPath)) {
    New-Item -ItemType Directory -Path "$VimDir\autoload" -Force | Out-Null
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim" -OutFile $plugPath
    Write-Success "vim-plug instalado en vimfiles"
}

if (-not (Test-Path $plugPathAlt)) {
    New-Item -ItemType Directory -Path "$VimDirAlt\autoload" -Force | Out-Null
    Copy-Item $plugPath $plugPathAlt -Force
    Write-Success "vim-plug instalado en .vim"
}

Write-Success "vim-plug listo"

# ================================================================
# STEP 7: Install plugins
# ================================================================
Write-Step "7/8 - Instalando plugins de Vim..."

try {
    $vimCmd = if (Test-Command "vim") { "vim" } else { "gvim" }
    & $vimCmd +PlugInstall +qall 2>$null
    Write-Success "Plugins instalados"
} catch {
    Write-Warn "No se pudieron instalar plugins automáticamente. Abre Vim y ejecuta :PlugInstall"
}

# ================================================================
# STEP 8: External tools
# ================================================================
Write-Step "8/8 - Herramientas externas..."

if (-not $SkipTools) {
    Write-Host ""
    Write-Info "¿Deseas instalar herramientas externas (linters, formatters)?"
    Write-Host "  [1] Todas las herramientas (recomendado)"
    Write-Host "  [2] Solo esenciales (ripgrep, fzf, prettier)"
    Write-Host "  [3] Omitir"
    Write-Host ""
    $choice = Read-Host "Opción [1-3] (default: 1)"
    if (-not $choice) { $choice = "1" }

    function Install-Essentials {
        switch ($pkgManager) {
            "scoop" {
                scoop install ripgrep 2>$null
                scoop install fzf 2>$null
            }
            "choco" {
                choco install ripgrep -y 2>$null
                choco install fzf -y 2>$null
            }
            "winget" {
                winget install BurntSushi.ripgrep.MSVC 2>$null
                winget install junegunn.fzf 2>$null
            }
        }
        npm install -g prettier eslint 2>$null
        Write-Success "Herramientas esenciales instaladas"
    }

    function Install-AllTools {
        Install-Essentials

        # Node.js tools
        npm install -g typescript ts-node markdownlint-cli sql-lint 2>$null
        Write-Success "Herramientas Node.js instaladas"

        # Python tools
        if (Test-Command "pip") {
            pip install --user vim-vint nginx-linter 2>$null
            Write-Success "Herramientas Python instaladas"
        } elseif (Test-Command "pip3") {
            pip3 install --user vim-vint nginx-linter 2>$null
            Write-Success "Herramientas Python instaladas"
        } else {
            Write-Warn "pip no encontrado. Instala Python para herramientas adicionales."
        }

        # C/C++ (via scoop or choco)
        if (-not (Test-Command "clangd")) {
            switch ($pkgManager) {
                "scoop" { scoop install llvm 2>$null }
                "choco" { choco install llvm -y 2>$null }
                "winget" { winget install LLVM.LLVM 2>$null }
            }
        }

        # PHP tools
        if (Test-Command "composer") {
            composer global require squizlabs/php_codesniffer 2>$null
            composer global require phpstan/phpstan 2>$null
            composer global require friendsofphp/php-cs-fixer 2>$null
            Write-Success "Herramientas PHP instaladas"
        } else {
            Write-Warn "Composer no encontrado. Instálalo para herramientas PHP."
        }

        # hadolint
        if (-not (Test-Command "hadolint")) {
            switch ($pkgManager) {
                "scoop" { scoop install hadolint 2>$null }
                "choco" { choco install hadolint -y 2>$null }
            }
        }
    }

    switch ($choice) {
        "1" { Install-AllTools }
        "2" { Install-Essentials }
        "3" { Write-Info "Omitiendo herramientas externas" }
    }
} else {
    Write-Info "Herramientas externas omitidas (-SkipTools)"
}

# ================================================================
# Done!
# ================================================================
Write-Host ""
Write-Host "╔══════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║          ¡Instalación exitosa!                   ║" -ForegroundColor Green
Write-Host "╚══════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Info "Config dir:     $ConfigDir"
Write-Info "Vimfiles:       $VimDir"
Write-Info "Vimrc:          $VimRC"
if ($backupNeeded) { Write-Info "Backup:         $BackupDir" }
Write-Host ""
Write-Info "Próximos pasos:"
Write-Host "  1. Abre Vim y espera que CoC instale las extensiones"
Write-Host "  2. Ejecuta :CocInfo para verificar"
Write-Host "  3. Configura tus conexiones de BD en plugin-config.vim"
Write-Host ""
Write-Info "Para actualizar:"
Write-Host "  cd $ConfigDir; git pull"
Write-Host ""
Write-Info "Para desinstalar:"
Write-Host "  .\install.ps1 -Uninstall"
Write-Host ""
