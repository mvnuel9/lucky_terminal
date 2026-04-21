# vim:ft=zsh ts=2 sw=2 sts=2
#
# Original agnoster's Theme - https://gist.github.com/3712874
# Mvnuel : Agnoster + palette personnalisée (hex truecolor).
# Fond segments : #251810 / #3a2a20 — aligné sur Mvnuel.itermcolors / palette commune.
# Copie alignée sur ../../linux/configs/mvnuel-agnoster.zsh-theme (install : macos/install.sh).

# --- Palette adaptative ------------------------------------------------------
# Terminal.app (macOS < Tahoe) ne supporte pas le truecolor 24-bit : les hex
# #RRGGBB en %K/%F sont mal interprétés et produisent du surlignage vert.
# On bascule alors sur les 16 couleurs ANSI (déjà customisées dans
# macos/mvnuel.terminal) + quelques indices xterm-256 pour les nuances.
# iTerm2, gnome-terminal, Windows Terminal : restent en truecolor (rendu fidèle).
if [[ "$COLORTERM" == (truecolor|24bit) ]]; then
  _MVNUEL_TRUECOLOR=1
elif [[ "$TERM_PROGRAM" == "Apple_Terminal" ]]; then
  _MVNUEL_TRUECOLOR=0
else
  _MVNUEL_TRUECOLOR=1
fi

if (( _MVNUEL_TRUECOLOR )); then
  MVNUEL_BG_SEG='#3a2a20'      ; MVNUEL_BG_VENV='#251810'
  MVNUEL_BG_GIT='#d4a060'      ; MVNUEL_BG_STATUS='#1a1210'
  MVNUEL_FG_ROOT='#d44040'     ; MVNUEL_FG_USER='#e0855a'
  MVNUEL_FG_GIT='#AA2727'      ; MVNUEL_FG_VENV='#d4a060'
  MVNUEL_FG_DIRTY='#e0a840'    ; MVNUEL_FG_CLEAN='#a8c870'
  MVNUEL_FG_JOB='#60c8d0'      ; MVNUEL_FG_ROOT_SYM='#e0a040'
  MVNUEL_FG_ERR='#d44040'      ; MVNUEL_FG_PATH='#a8c870'
else
  # Terminal.app : palette ANSI (profil mvnuel.terminal) + xterm-256 pour nuances
  MVNUEL_BG_SEG='237'          ; MVNUEL_BG_VENV='234'
  MVNUEL_BG_GIT='yellow'       ; MVNUEL_BG_STATUS='black'
  MVNUEL_FG_ROOT='red'         ; MVNUEL_FG_USER='magenta'
  MVNUEL_FG_GIT='red'          ; MVNUEL_FG_VENV='yellow'
  MVNUEL_FG_DIRTY='yellow'     ; MVNUEL_FG_CLEAN='cyan'
  MVNUEL_FG_JOB='blue'         ; MVNUEL_FG_ROOT_SYM='yellow'
  MVNUEL_FG_ERR='red'          ; MVNUEL_FG_PATH='cyan'
fi
# -----------------------------------------------------------------------------

CURRENT_BG='NONE'

() {
  local LC_ALL="" LC_CTYPE="en_US.UTF-8"
  SEGMENT_SEPARATOR=$'\ue0b0'
}

# $1 bg  $2 fg  $3 texte
prompt_segment() {
  local bg fg
  [[ -n $1 ]] && bg="%K{$1}" || bg="%k"
  [[ -n $2 ]] && fg="%F{$2}" || fg="%f"
  if [[ $CURRENT_BG != 'NONE' && $1 != $CURRENT_BG ]]; then
    echo -n " %{$bg%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR%{$fg%} "
  else
    echo -n "%{$bg%}%{$fg%} "
  fi
  CURRENT_BG=$1
  [[ -n $3 ]] && echo -n $3
}

prompt_end() {
  if [[ -n $CURRENT_BG ]]; then
    echo -n " %{%k%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR"
  else
    echo -n "%{%k%}"
  fi
  echo -n "%{%f%}"
  CURRENT_BG=''
}

# Nom d’utilisateur uniquement (palette Mvnuel — root / user)
prompt_context() {
  if [[ $UID -eq 0 ]]; then
    prompt_segment "$MVNUEL_BG_SEG" "$MVNUEL_FG_ROOT" "%n"
  else
    prompt_segment "$MVNUEL_BG_SEG" "$MVNUEL_FG_USER" "%n"
  fi
}

prompt_git() {
  (( $+commands[git] )) || return
  local PL_BRANCH_CHAR
  () {
    local LC_ALL="" LC_CTYPE="en_US.UTF-8"
    PL_BRANCH_CHAR=$'\ue0a0'
  }
  local ref dirty mode repo_path
  repo_path=$(git rev-parse --git-dir 2>/dev/null)

  if $(git rev-parse --is-inside-work-tree >/dev/null 2>&1); then
    dirty=$(parse_git_dirty)
    ref=$(git symbolic-ref HEAD 2> /dev/null) || ref="➦ $(git rev-parse --short HEAD 2> /dev/null)"
    if [[ -n $dirty ]]; then
      prompt_segment "$MVNUEL_BG_GIT" "$MVNUEL_FG_GIT"
    else
      prompt_segment "$MVNUEL_BG_GIT" "$MVNUEL_FG_GIT"
    fi

    if [[ -e "${repo_path}/BISECT_LOG" ]]; then
      mode=" <B>"
    elif [[ -e "${repo_path}/MERGE_HEAD" ]]; then
      mode=" >M<"
    elif [[ -e "${repo_path}/rebase" || -e "${repo_path}/rebase-apply" || -e "${repo_path}/rebase-merge" || -e "${repo_path}/../.dotest" ]]; then
      mode=" >R>"
    fi

    setopt promptsubst
    autoload -Uz vcs_info

    zstyle ':vcs_info:*' enable git
    zstyle ':vcs_info:*' get-revision true
    zstyle ':vcs_info:*' check-for-changes true
    zstyle ':vcs_info:*' stagedstr '+'
    zstyle ':vcs_info:*' unstagedstr '-'
    zstyle ':vcs_info:*' formats ' %u%c'
    zstyle ':vcs_info:*' actionformats ' %u%c'
    vcs_info
    echo -n "${ref/refs\/heads\//$PL_BRANCH_CHAR }${vcs_info_msg_0_%% }${mode}"
  fi
}

prompt_bzr() {
    (( $+commands[bzr] )) || return
    if (bzr status >/dev/null 2>&1); then
        status_mod=`bzr status | head -n1 | grep "modified" | wc -m`
        status_all=`bzr status | head -n1 | wc -m`
        revision=`bzr log | head -n2 | tail -n1 | sed 's/^revno: //'`
        if [[ $status_mod -gt 0 ]] ; then
            prompt_segment "$MVNUEL_BG_SEG" "$MVNUEL_FG_ERR"
            echo -n "bzr@"$revision "✚ "
        else
            if [[ $status_all -gt 0 ]] ; then
                prompt_segment "$MVNUEL_BG_SEG" "$MVNUEL_FG_DIRTY"
                echo -n "bzr@"$revision

            else
                prompt_segment "$MVNUEL_BG_SEG" "$MVNUEL_FG_CLEAN"
                echo -n "bzr@"$revision
            fi
        fi
    fi
}

prompt_hg() {
  (( $+commands[hg] )) || return
  local rev status
  if $(hg id >/dev/null 2>&1); then
    if $(hg prompt >/dev/null 2>&1); then
      if [[ $(hg prompt "{status|unknown}") = "?" ]]; then
        prompt_segment "$MVNUEL_BG_SEG" "$MVNUEL_FG_ERR"
        st='±'
      elif [[ -n $(hg prompt "{status|modified}") ]]; then
        prompt_segment "$MVNUEL_BG_SEG" "$MVNUEL_FG_DIRTY"
        st='±'
      else
        prompt_segment "$MVNUEL_BG_SEG" "$MVNUEL_FG_CLEAN"
      fi
      echo -n $(hg prompt "☿ {rev}@{branch}") $st
    else
      st=""
      rev=$(hg id -n 2>/dev/null | sed 's/[^-0-9]//g')
      branch=$(hg id -b 2>/dev/null)
      if `hg st | grep -q "^\?"`; then
        prompt_segment "$MVNUEL_BG_SEG" "$MVNUEL_FG_ERR"
        st='±'
      elif `hg st | grep -q "^[MA]"`; then
        prompt_segment "$MVNUEL_BG_SEG" "$MVNUEL_FG_DIRTY"
        st='±'
      else
        prompt_segment "$MVNUEL_BG_SEG" "$MVNUEL_FG_CLEAN"
      fi
      echo -n "☿ $rev@$branch" $st
    fi
  fi
}

prompt_dir() {
  # prompt_segment 008 010 $(basename `pwd`)
}

prompt_virtualenv() {
  if [[ -n "${CONDA_PROMPT_MODIFIER:-}" ]]; then
    prompt_segment "$MVNUEL_BG_VENV" "$MVNUEL_FG_VENV" ${CONDA_PROMPT_MODIFIER:1:-2}
    return
  fi
  [[ -n "$VIRTUAL_ENV" ]] || return
  local env_name="${VIRTUAL_ENV_PROMPT:-$(basename "$VIRTUAL_ENV")}"
  [[ -n "$env_name" ]] || return
  prompt_segment "$MVNUEL_BG_VENV" "$MVNUEL_FG_VENV" "$env_name"
}

prompt_status() {
  local symbols
  symbols=()
  [[ $RETVAL -ne 0 ]] && symbols+="%{%F{$MVNUEL_FG_ERR}%}✘"
  [[ $UID -eq 0 ]] && symbols+="%{%F{$MVNUEL_FG_ROOT_SYM}%}⚡"
  [[ $(jobs -l | wc -l) -gt 0 ]] && symbols+="%{%F{$MVNUEL_FG_JOB}%}⚙"

  [[ -n "$symbols" ]] && prompt_segment "$MVNUEL_BG_STATUS" "default" "$symbols"
}

prompt_head() {
  echo "\r               "
  echo "\r %{%F{$MVNUEL_FG_PATH}%}[%64<..<%~%<<]"
}

build_prompt() {
  RETVAL=$?
  prompt_head
  prompt_status
  prompt_virtualenv
  prompt_context
  # prompt_dir
  prompt_git
  prompt_bzr
  prompt_hg
  prompt_end
}

PROMPT='%{%f%b%k%}$(build_prompt) '
