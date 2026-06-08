#!/data/data/com.termux/files/usr/bin/bash
set -e

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
TARGET="$PREFIX/bin/matrix"

printf '\n\033[1;32mInstalling Termux Matrix Binary Rain...\033[0m\n'
install -m 755 "$PROJECT_DIR/matrix.sh" "$TARGET"
printf '\033[1;32mInstalled successfully.\033[0m\n'
printf 'Run with: \033[1;97mmatrix\033[0m\n\n'
