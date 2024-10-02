# ディレクトリ構造
.zshrcはホームディレクトリ直下におくように

それ以外は.config ディレクトリにおくように
# pythonのパッケージを使うための設定
```
brew install python3
```

```
pip3 install --user pynvim --break-system-packages
```
# starshipのインストール
```
brew install starship
```
# Neovimのインストール
```
brew install neovim
```
# oh-my-zshのインストール
```
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

# zsh-autosuggestions のインストール
```
brew install zsh-autosuggestions
```
# zsh-syntax-highlighting のインストール
```
brew install zsh-syntax-highlighting
```

# Astronvimのインストール
```
git clone --depth 1 https://github.com/AstroNvim/template ~/.config/nvim
rm -rf ~/.config/nvim/.git
```
