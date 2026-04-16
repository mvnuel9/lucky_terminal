" Vim — Mvnuel (macOS) — voir macos/README.md
" Powerline : installé via pipx (macos/install.sh). Le chemin dépend de la version Python du venv.

set laststatus=2
set t_Co=256
set showcmd

" Premier répertoire pipx valide pour powerline/bindings/vim
for p in [
      \ expand('~/.local/pipx/venvs/powerline-status/lib/python3.13/site-packages/powerline/bindings/vim'),
      \ expand('~/.local/pipx/venvs/powerline-status/lib/python3.12/site-packages/powerline/bindings/vim'),
      \ expand('~/.local/pipx/venvs/powerline-status/lib/python3.11/site-packages/powerline/bindings/vim'),
      \ expand('~/.local/pipx/venvs/powerline-status/lib/python3.10/site-packages/powerline/bindings/vim')
      \ ]
  if isdirectory(p)
    execute 'set rtp+=' . fnameescape(p)
    break
  endif
endfor
