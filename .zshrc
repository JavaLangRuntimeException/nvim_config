# ================================================================
#  1. 環境設定 (最優先で読み込む)
# ================================================================
# Homebrew の設定
# これを一番最初に読み込むことで、以降の処理で brew コマンドが使えるようになる
if [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi


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

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# Unity CLI
if [ -f "$HOME/.unity/env" ]; then
  . "$HOME/.unity/env"
fi


# ================================================================
#  5. マウスモードのリセット
# ================================================================
# ssh が切れたり claude (fullscreen TUI) を強制終了したりすると、
# ターミナルのマウスレポートが ON のまま残り、スクロールのたびに
# "64;12;5M" のような英数字がプロンプトに入力されてしまう。
# プロンプトを表示する前に毎回マウス関連のモードを OFF に戻して防ぐ。
#   1000/1002/1003: マウストラッキング
#   1005/1006/1015: マウス座標のエンコード形式
#   1004: フォーカスイベント (OFF にしないと "[I" "[O" が出ることがある)
_reset_terminal_mouse_mode() {
  print -n '\e[?1000l\e[?1002l\e[?1003l\e[?1005l\e[?1006l\e[?1015l\e[?1004l'
}
autoload -Uz add-zsh-hook
add-zsh-hook precmd _reset_terminal_mouse_mode


# ================================================================
#  6. PC 固有の設定 (git 管理外)
# ================================================================
# API キーなど、リポジトリに入れたくない設定は ~/.zshrc.local に書く
if [ -f "$HOME/.zshrc.local" ]; then
  source "$HOME/.zshrc.local"
fi
