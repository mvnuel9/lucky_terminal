# Mvnuel — macOS (fichier source : macos/configs/.zshrc)
# Copié vers ~/.zshrc par macos/install.sh

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
  export ZSH=~/.oh-my-zsh

# Afficher le venv dans le thème (segment Powerline)
export VIRTUAL_ENV_DISABLE_PROMPT=1

# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="mvnuel-agnoster"

plugins=(
  git
  zsh-syntax-highlighting
  zsh-autosuggestions
)

source $ZSH/oh-my-zsh.sh

# ls : palette Mvnuel. GNU coreutils : brew install coreutils
# Terminal.app (macOS < Tahoe) ne gère pas le truecolor → on bascule sur
# ~/.dircolors.terminal (xterm-256) pour éviter le surlignage vert sur les noms
# de dossiers. iTerm2 / autres → ~/.dircolors (truecolor hex).
if [[ "$(uname -s)" == "Darwin" ]] && [[ -d "$(brew --prefix 2>/dev/null)/opt/coreutils" ]]; then
  export PATH="$(brew --prefix)/opt/coreutils/libexec/gnubin:$PATH"
fi
if command -v dircolors >/dev/null 2>&1; then
  if [[ "$TERM_PROGRAM" == "Apple_Terminal" && "$COLORTERM" != (truecolor|24bit) && -f ~/.dircolors.terminal ]]; then
    eval "$(dircolors -b ~/.dircolors.terminal)"
  elif [[ -f ~/.dircolors ]]; then
    eval "$(dircolors -b ~/.dircolors)"
  fi
fi

alias cls="clear"

source ~/.aliases
source ~/.functions
