#!/usr/bin/env bash
# dotfiles のセットアップスクリプト
#
# 使い方:
#   ./install.sh               ツールのインストール + シンボリックリンクの作成
#   ./install.sh --link-only   シンボリックリンクの作成だけ行う
#
# 既にあるファイルは ~/.dotfiles_backup/<日時>/ に退避してからリンクを張る
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles_backup/$(date +%Y%m%d_%H%M%S)"

info() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33mwarn:\033[0m %s\n' "$*" >&2; }

# $1: リポジトリ内のパス, $2: リンクを張る場所
link() {
  local src="$DOTFILES/$1" dst="$2"

  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
    echo "  ok      $dst"
    return
  fi

  mkdir -p "$(dirname "$dst")"
  if [ -e "$dst" ] || [ -L "$dst" ]; then
    local backup="$BACKUP_DIR/${dst#"$HOME"/}"
    mkdir -p "$(dirname "$backup")"
    mv "$dst" "$backup"
    echo "  backup  $dst -> $backup"
  fi
  ln -s "$src" "$dst"
  echo "  link    $dst -> $src"
}

link_all() {
  info "シンボリックリンクを作成"
  link .zshrc             "$HOME/.zshrc"
  link .zprofile          "$HOME/.zprofile"
  link .zshenv            "$HOME/.zshenv"
  link .vimrc             "$HOME/.vimrc"
  link .tmux.conf         "$HOME/.tmux.conf"
  link .wezterm.lua       "$HOME/.wezterm.lua"
  link .gitconfig         "$HOME/.gitconfig"
  link .gitignore_global  "$HOME/.gitignore_global"
  link .local/bin/dev     "$HOME/.local/bin/dev"
  link starship.toml      "$HOME/.config/starship.toml"
  link nvim               "$HOME/.config/nvim"
  link lazygit/config.yml "$HOME/Library/Application Support/lazygit/config.yml"
}

install_tools() {
  if ! command -v brew >/dev/null 2>&1; then
    if [ -x /opt/homebrew/bin/brew ]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    else
      warn "Homebrew がありません。README の手順で先にインストールしてください"
      exit 1
    fi
  fi

  info "Homebrew パッケージをインストール (Brewfile)"
  brew bundle --file="$DOTFILES/Brewfile"

  info "oh-my-zsh"
  if [ -d "$HOME/.oh-my-zsh" ]; then
    echo "  インストール済み"
  else
    # KEEP_ZSHRC=yes: このリポジトリの .zshrc を上書きさせない
    RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c \
      "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  fi

  info "oh-my-zsh プラグイン"
  local plugins_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins"
  local name
  for name in zsh-autosuggestions zsh-syntax-highlighting; do
    if [ -d "$plugins_dir/$name" ]; then
      echo "  $name: インストール済み"
    else
      git clone --depth 1 "https://github.com/zsh-users/$name" "$plugins_dir/$name"
    fi
  done

  info "tree-sitter-cli (nvim-treesitter 用)"
  if command -v tree-sitter >/dev/null 2>&1; then
    echo "  インストール済み"
  else
    npm install -g tree-sitter-cli@0.24.7 || warn "tree-sitter-cli のインストールに失敗しました"
  fi

  info "pynvim"
  python3 -m pip install --user --break-system-packages pynvim || warn "pynvim のインストールに失敗しました"

  info "vim-plug (.vimrc 用)"
  local plug="$HOME/.vim/autoload/plug.vim"
  if [ -f "$plug" ]; then
    echo "  インストール済み"
  else
    curl -fLo "$plug" --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  fi
}

case "${1:-}" in
  --link-only) link_all ;;
  "") install_tools; link_all ;;
  *) echo "usage: $0 [--link-only]" >&2; exit 1 ;;
esac

if [ -d "$BACKUP_DIR" ]; then
  info "元のファイルは $BACKUP_DIR に退避しました"
fi
info "完了。新しいターミナルを開くか exec zsh で反映されます"
