# nvim_config (dotfiles)

Neovim (AstroNvim) / zsh / WezTerm などの設定をまとめたリポジトリ。
`install.sh` を実行すると、ホームディレクトリの各設定ファイルがこのリポジトリへのシンボリックリンクになる。

| リポジトリ内 | リンク先 | 内容 |
| --- | --- | --- |
| `.zshrc` | `~/.zshrc` | oh-my-zsh + starship、エイリアス |
| `.zprofile` / `.zshenv` | `~/.zprofile` / `~/.zshenv` | Homebrew・rbenv などの PATH |
| `nvim/` | `~/.config/nvim` | Neovim (AstroNvim v4) |
| `starship.toml` | `~/.config/starship.toml` | プロンプト |
| `.wezterm.lua` | `~/.wezterm.lua` | WezTerm |
| `.local/bin/dev` | `~/.local/bin/dev` | `dev [dir]` で WezTerm に開発用レイアウトを開く |
| `.tmux.conf` | `~/.tmux.conf` | tmux |
| `.vimrc` | `~/.vimrc` | Vim (vim-plug) |
| `.gitconfig` / `.gitignore_global` | `~/.gitconfig` / `~/.gitignore_global` | git |
| `lazygit/config.yml` | `~/Library/Application Support/lazygit/config.yml` | lazygit |
| `Brewfile` | — | 必要な Homebrew パッケージ |

## 新しい Mac でのセットアップ

### 1. Xcode Command Line Tools と Homebrew

```sh
xcode-select --install
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/opt/homebrew/bin/brew shellenv)"
```

### 2. このリポジトリを clone して install.sh を実行

```sh
git clone https://github.com/JavaLangRuntimeException/nvim_config.git ~/nvim_config
cd ~/nvim_config
./install.sh
```

`install.sh` がやること:

- `Brewfile` のパッケージをインストール (neovim, starship, wezterm, ripgrep, lazygit など)
- oh-my-zsh と プラグイン (zsh-autosuggestions, zsh-syntax-highlighting) をインストール
- tree-sitter-cli@0.24.7 (npm)、pynvim (pip)、vim-plug をインストール
- 上の表のとおりシンボリックリンクを作成 (既存のファイルは `~/.dotfiles_backup/<日時>/` に退避)

何度実行しても大丈夫。

> **リポジトリは `~/nvim_config` から動かさないこと。** リンクがこの場所を指しているので、動かした場合は移動先で `./install.sh --link-only` を実行し直す。

### 3. 起動

```sh
exec zsh   # またはターミナルを開き直す
nvim       # 初回起動時にプラグインと LSP (Mason) が自動でインストールされる
```

### 4. 必要に応じて

```sh
gh auth login                                   # GitHub CLI (octo.nvim / WezTerm の Ctrl+B, Ctrl+V で使う)
curl -fsSL https://claude.ai/install.sh | bash  # Claude Code (dev レイアウトで使う)
```

- Copilot: nvim で `:Copilot auth`
- Vim のプラグイン: vim で `:PlugInstall`
- Mason の `jdtls` (Java) と `omnisharp` (C#) は、それぞれ JDK と .NET SDK が入っていないとインストールに失敗する

## 日々の使い方

ホームの設定ファイルはこのリポジトリへのリンクなので、`~/.zshrc` などを直接編集すればリポジトリにも反映される。
変更したら commit / push する。

```sh
cd ~/nvim_config
git add -A && git commit -m "Update .zshrc" && git push
```

別の PC では `git pull` するだけで反映される (新しいファイルを追加したときは `./install.sh --link-only` も)。

### PC ごとの設定・秘密情報

API キーやその PC だけで使う設定は `~/.zshrc.local` に書く。`.zshrc` の最後で読み込まれ、git には入らない。

### 元に戻す

`install.sh` が退避したファイルは `~/.dotfiles_backup/<日時>/` にある。リンクを消してそこから戻せば元通り。

## トラブルシューティング

### スクロールすると `64;12;5M` のような英数字がプロンプトに入力される

ssh が切れたり、Claude Code (fullscreen TUI) などマウスを使うアプリが強制終了したりすると、
ターミナルのマウスレポートモードが ON のまま残り、スクロール操作がそのまま文字として入力されてしまう。

`.zshrc` の「5. マウスモードのリセット」で、プロンプトを出すたびにマウスモードを OFF に戻しているので、
文字が出てしまったら **Ctrl+C** で新しいプロンプトを出せば直る。それでもおかしいときは `reset` を実行する。
