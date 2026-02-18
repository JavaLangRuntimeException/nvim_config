# ================================================================
#  1. 環境設定 (最優先で読み込む)
# ================================================================
# Homebrew for Linux (Linuxbrew) の設定
# これを一番最初に読み込むことで、以降の処理で brew コマンドが使えるようになる
eval "$(/opt/homebrew/bin/brew shellenv)"


# ================================================================
#  2. Oh My Zsh の設定
# ================================================================
# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Starshipを使うため、Oh My Zshのテーマは無効にする
ZSH_THEME=""

# Oh My Zsh で読み込むプラグインのリスト
# gitはデフォルト。zsh-autosuggestionsとzsh-syntax-highlightingを追加
plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
)

# Oh My Zsh 本体を読み込む
# plugins=(...) の設定より後に書くこと
source "$ZSH/oh-my-zsh.sh"


# ================================================================
#  3. Starship の設定
# ================================================================
# Oh My Zshのテーマの代わりにStarshipをプロンプトとして使う
eval "$(starship init zsh)"


# ================================================================
#  4. 個人の設定 (エイリアスなど)
# ================================================================
# ここに個別のエイリアスなどを追加していく
# 例: alias ls='ls -lha'
#

# nvim を n で起動
alias n='nvim'

# s hogehoge で Google 検索をブラウザで開く
s() {
  open "https://www.google.com/search?q=$(echo "$@" | sed 's/ /+/g')"
}

alias lg='lazygit'

# nvim のカスタム設定一覧を表示
alias nhelp='nvim +UserHelp'
export PATH="$HOME/.local/bin:$PATH"
