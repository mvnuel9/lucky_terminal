#!/usr/bin/env bash
#
# Étape 3/3 Linux : installe les plug-ins Oh My Zsh, le thème Mvnuel,
# les configs ~/.zshrc / ~/.dircolors, et le profil GNOME Terminal (dconf).
#
# Usage : depuis la racine du dépôt —  ./linux/install_profile.sh
#
# Variables d'environnement (avancé) :
#   ZSH_SYNTAX_HIGHLIGHTING_REF   Ref git (tag/branch) de zsh-syntax-highlighting
#                                 (défaut : master). Ex. 0.8.0 pour épingler.
#   ZSH_AUTOSUGGESTIONS_REF       Ref git de zsh-autosuggestions
#                                 (défaut : master). Ex. v0.7.1 pour épingler.
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../scripts/_common.sh
. "${SCRIPT_DIR}/../scripts/_common.sh"

parse_common_args "$@"
for arg in ${LUCKY_REMAINING_ARGS[@]+"${LUCKY_REMAINING_ARGS[@]}"}; do
  case "$arg" in
    --help | -h)
      awk '/^#/{print; next} {exit}' "$0"
      exit 0
      ;;
    *) log_warn "Option inconnue ignorée : $arg" ;;
  esac
done

CONFIGS="${SCRIPT_DIR}/configs"
ZSH_CUSTOM="${HOME}/.oh-my-zsh/custom/plugins"

[[ -f "${CONFIGS}/.zshrc" ]] || die "Dépôt incomplet : ${CONFIGS}/.zshrc introuvable." "$LUCKY_EXIT_MISSING_FILE"
[[ -d "${HOME}/.oh-my-zsh" ]] || die "Oh My Zsh manquant. Lancez d'abord : ./linux/install_terminal.sh" "$LUCKY_EXIT_MISSING_FILE"

require_cmd git "sudo apt install git"
require_cmd dconf "sudo apt install dconf-cli"

log_info "=== Installation du profil Mvnuel (Linux / GNOME) ==="

log_info "[1/3] Plug-ins Oh My Zsh (syntax-highlighting, autosuggestions)..."
lucky_run mkdir -p "${ZSH_CUSTOM}"

ZSH_SYNTAX_HIGHLIGHTING_REF="${ZSH_SYNTAX_HIGHLIGHTING_REF:-master}"
ZSH_AUTOSUGGESTIONS_REF="${ZSH_AUTOSUGGESTIONS_REF:-master}"

clone_omz_plugin() {
  local url="$1"
  local ref="$2"
  local name
  name="$(basename "$url" .git)"
  if [[ -d "${ZSH_CUSTOM}/${name}" ]]; then
    log_info "    ${name} déjà présent — clone ignoré."
  else
    log_info "    clone ${name} @ ${ref}"
    lucky_run git clone --depth=1 --branch "$ref" "$url" "${ZSH_CUSTOM}/${name}"
  fi
}
clone_omz_plugin "https://github.com/zsh-users/zsh-syntax-highlighting.git" "$ZSH_SYNTAX_HIGHLIGHTING_REF"
clone_omz_plugin "https://github.com/zsh-users/zsh-autosuggestions.git" "$ZSH_AUTOSUGGESTIONS_REF"

log_info "[2/3] Copie des configs (.zshrc, dircolors, thème agnoster)..."
lucky_run cp "${CONFIGS}/.zshrc" "${HOME}/.zshrc"
lucky_run cp "${CONFIGS}/dircolors" "${HOME}/.dircolors"
lucky_run cp "${CONFIGS}/mvnuel-agnoster.zsh-theme" "${HOME}/.oh-my-zsh/themes/mvnuel-agnoster.zsh-theme"

log_info "[3/3] Profil GNOME Terminal « Mvnuel » via dconf..."
if [[ "${LUCKY_DRY_RUN:-0}" -eq 1 ]]; then
  log_info "[dry-run] dconf load/write sur /org/gnome/terminal/legacy/profiles:/"
else
  dconf load /org/gnome/terminal/legacy/profiles:/:fb358fc9-49ea-4252-ad34-1d25c649e633/ < "${CONFIGS}/terminal_profile.dconf"

  add_list_id=fb358fc9-49ea-4252-ad34-1d25c649e633
  old_list=$(dconf read /org/gnome/terminal/legacy/profiles:/list | tr -d "]")
  if [[ -z "$old_list" ]]; then
    front_list="["
  else
    front_list="$old_list, "
  fi
  new_list="$front_list'$add_list_id']"
  dconf write /org/gnome/terminal/legacy/profiles:/list "$new_list"
  dconf write /org/gnome/terminal/legacy/profiles:/default "'$add_list_id'"
fi

log_info "[+] Bascule du shell par défaut vers zsh..."
lucky_run chsh -s "$(command -v zsh)"

echo ""
log_ok "Étape Profil terminée."
log_info "Ouvre un nouveau terminal : le thème Mvnuel devrait apparaître."
