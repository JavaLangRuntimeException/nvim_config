# Homebrew (Apple Silicon: /opt/homebrew, Intel: /usr/local)
if [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi
if [ -x /usr/local/bin/brew ]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi


# Added by Toolbox App
export PATH="$PATH:/usr/local/bin"


# Created by `pipx` on 2024-10-02 01:07:18
export PATH="$PATH:$HOME/.local/bin"

# Added by `rbenv init` on Wed Dec 25 11:41:14 JST 2024
if command -v rbenv >/dev/null 2>&1; then
  eval "$(rbenv init - --no-rehash zsh)"
fi

# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
source ~/.orbstack/shell/init.zsh 2>/dev/null || :


# Added by Antigravity CLI installer
export PATH="$HOME/.local/bin:$PATH"
