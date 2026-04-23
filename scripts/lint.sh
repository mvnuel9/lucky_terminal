#!/usr/bin/env bash
#
# Lance shellcheck + shfmt sur les scripts Bash et (si pwsh est dispo)
# PSScriptAnalyzer via scripts/lint.ps1.
#
# Usage :
#   ./scripts/lint.sh                  # vérifie (rapport)
#   ./scripts/lint.sh --fix            # applique shfmt -w + Invoke-Formatter
#   ./scripts/lint.sh --skip-ps        # n'appelle pas lint.ps1 même si pwsh dispo
#   ./scripts/lint.sh --help
#
# Détecte automatiquement les scripts via `git ls-files '*.sh'` pour rester
# cohérent avec ce qui est versionné (inclut macos/, linux/, scripts/, etc.).
# Exit codes : 0 = OK, 1 = erreur de lint, 2 = outil manquant.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT" || exit 1

FIX_MODE=0
SKIP_PS=0
for arg in "$@"; do
  case "$arg" in
    --fix)
      FIX_MODE=1
      ;;
    --skip-ps)
      SKIP_PS=1
      ;;
    -h | --help)
      # N'affiche que le bloc de commentaires de tête (jusqu'à la première ligne non-#).
      awk '/^#/{print; next} {exit}' "$0"
      exit 0
      ;;
    *)
      echo "Option inconnue : $arg" >&2
      echo "Voir : $0 --help" >&2
      exit 2
      ;;
  esac
done

log_info() { printf '[INFO] %s\n' "$*"; }
log_warn() { printf '[WARN] %s\n' "$*" >&2; }
log_error() { printf '[ERROR] %s\n' "$*" >&2; }

# Liste des scripts .sh versionnés (fallback sur find si pas de git).
if command -v git >/dev/null 2>&1 && git -C "$REPO_ROOT" rev-parse >/dev/null 2>&1; then
  mapfile -t SCRIPTS < <(git -C "$REPO_ROOT" ls-files '*.sh')
else
  mapfile -t SCRIPTS < <(find . -type f -name '*.sh' -not -path './.git/*' | sed 's|^\./||')
fi

if [[ ${#SCRIPTS[@]} -eq 0 ]]; then
  log_warn "Aucun script .sh trouvé — rien à linter."
  exit 0
fi

log_info "${#SCRIPTS[@]} script(s) Bash à analyser."

EXIT_CODE=0

# --- shellcheck ---
if command -v shellcheck >/dev/null 2>&1; then
  log_info "shellcheck $(shellcheck --version | awk '/version:/{print $2}')"
  if ! shellcheck -x "${SCRIPTS[@]}"; then
    EXIT_CODE=1
    log_error "shellcheck a signalé des problèmes."
  else
    log_info "shellcheck : OK."
  fi
else
  log_warn "shellcheck introuvable."
  log_warn "Installation :"
  log_warn "  Ubuntu/Debian : sudo apt install shellcheck"
  log_warn "  macOS (brew)  : brew install shellcheck"
  log_warn "  Binaire       : https://github.com/koalaman/shellcheck/releases"
  EXIT_CODE=2
fi

# --- shfmt ---
if command -v shfmt >/dev/null 2>&1; then
  log_info "shfmt $(shfmt --version)"
  if [[ $FIX_MODE -eq 1 ]]; then
    log_info "Mode --fix : reformatage en place (shfmt -w)."
    shfmt -i 2 -bn -ci -w "${SCRIPTS[@]}"
    log_info "shfmt : fichiers reformatés."
  else
    if ! shfmt -i 2 -bn -ci -d "${SCRIPTS[@]}"; then
      EXIT_CODE=1
      log_error "shfmt a détecté des différences de format. Relance avec --fix pour appliquer."
    else
      log_info "shfmt : format OK."
    fi
  fi
else
  log_warn "shfmt introuvable."
  log_warn "Installation :"
  log_warn "  Ubuntu (snap) : sudo snap install shfmt"
  log_warn "  macOS (brew)  : brew install shfmt"
  log_warn "  Go install    : go install mvdan.cc/sh/v3/cmd/shfmt@latest"
  log_warn "  Binaire       : https://github.com/mvdan/sh/releases"
  if [[ $EXIT_CODE -eq 0 ]]; then EXIT_CODE=2; fi
fi

# --- PSScriptAnalyzer via pwsh (si disponible) ---
if [[ $SKIP_PS -eq 0 ]] && command -v pwsh >/dev/null 2>&1; then
  log_info "pwsh détecté : délégation à scripts/lint.ps1 pour PSScriptAnalyzer."
  PS_ARGS=()
  if [[ $FIX_MODE -eq 1 ]]; then
    PS_ARGS+=("-Fix")
  fi
  ps_rc=0
  pwsh -NoProfile -File "${REPO_ROOT}/scripts/lint.ps1" "${PS_ARGS[@]}" || ps_rc=$?
  if [[ $ps_rc -eq 2 ]]; then
    log_warn "PSScriptAnalyzer manquant : étape PS ignorée (installer via 'Install-Module PSScriptAnalyzer')."
    if [[ $EXIT_CODE -eq 0 ]]; then EXIT_CODE=2; fi
  elif [[ $ps_rc -ne 0 ]]; then
    EXIT_CODE=1
  fi
elif [[ $SKIP_PS -eq 0 ]]; then
  log_info "pwsh introuvable : lint PowerShell ignoré. (Utilise scripts/lint.ps1 depuis Windows / pwsh installé.)"
fi

exit "$EXIT_CODE"
