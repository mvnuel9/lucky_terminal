#!/usr/bin/env bash
#
# tests/smoke.sh — Smoke tests Bash pour Lucky Terminal.
#
# Ne fait AUCUN effet de bord : pas d'install, pas de suppression réelle, pas
# de téléchargement réseau. Vérifie trois choses :
#
#   1. `bash -n` passe sur chaque script *.sh versionné (syntaxe).
#   2. `<script> --help` renvoie 0 pour chaque script utilisateur de l'OS courant.
#   3. `<script> --dry-run --yes` renvoie 0 sur purge_zsh / uninstall de l'OS courant.
#
# Usage :
#   ./tests/smoke.sh                          # auto-détection OS
#   ./tests/smoke.sh --os linux               # force linux
#   ./tests/smoke.sh --os macos               # force macos
#   ./tests/smoke.sh --skip-dry-run           # saute l'étape 3
#   ./tests/smoke.sh --verbose                # garde la sortie des scripts
#   ./tests/smoke.sh --help
#
# Exit codes : 0 si tout passe, 1 si au moins un test échoue, 3 si mauvais usage.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
# shellcheck source=../scripts/_common.sh
. "${REPO_ROOT}/scripts/_common.sh"

TARGET_OS=""
SKIP_DRY_RUN=0
SMOKE_VERBOSE=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --os)
      TARGET_OS="${2:-}"
      shift 2
      ;;
    --skip-dry-run)
      SKIP_DRY_RUN=1
      shift
      ;;
    --verbose | -v)
      SMOKE_VERBOSE=1
      shift
      ;;
    --help | -h)
      awk '/^#/{print; next} {exit}' "$0"
      exit "$LUCKY_EXIT_OK"
      ;;
    *)
      log_error "Option inconnue : $1"
      log_info "Voir : $0 --help"
      exit "$LUCKY_EXIT_USAGE"
      ;;
  esac
done

if [[ -z "$TARGET_OS" ]]; then
  TARGET_OS="$(lucky_os)"
fi

log_info "=== Smoke test Bash — OS ciblé : $TARGET_OS ==="

failures=0
total=0

record() {
  local label="$1"
  local rc="$2"
  total=$((total + 1))
  if [[ "$rc" -eq 0 ]]; then
    log_ok "PASS  $label"
  else
    failures=$((failures + 1))
    log_error "FAIL  $label (rc=$rc)"
  fi
}

run_test() {
  # run_test "label" cmd args...
  local label="$1"
  shift
  local rc=0
  if [[ "$SMOKE_VERBOSE" -eq 1 ]]; then
    "$@" || rc=$?
  else
    "$@" >/dev/null 2>&1 || rc=$?
  fi
  record "$label" "$rc"
}

rel_path() {
  # Affiche un chemin relatif à REPO_ROOT, portable sans `realpath --relative-to`.
  local abs="$1"
  case "$abs" in
    "$REPO_ROOT"/*) printf '%s' "${abs#"$REPO_ROOT"/}" ;;
    *) printf '%s' "$abs" ;;
  esac
}

# --- 1) Syntax check sur tous les *.sh versionnés ----------------------------
log_info "[1/3] bash -n sur les scripts *.sh..."
SH_FILES=()
if command -v git >/dev/null 2>&1 && git -C "$REPO_ROOT" rev-parse >/dev/null 2>&1; then
  while IFS= read -r line; do
    [[ -n "$line" ]] && SH_FILES+=("$REPO_ROOT/$line")
  done < <(git -C "$REPO_ROOT" ls-files '*.sh')
else
  while IFS= read -r line; do
    [[ -n "$line" ]] && SH_FILES+=("$line")
  done < <(find "$REPO_ROOT" -type f -name '*.sh' -not -path '*/.git/*')
fi

if [[ ${#SH_FILES[@]} -eq 0 ]]; then
  log_warn "Aucun script *.sh détecté — étape 1 ignorée."
else
  for script in "${SH_FILES[@]}"; do
    run_test "bash -n $(rel_path "$script")" bash -n "$script"
  done
fi

# --- 2) --help exit 0 --------------------------------------------------------
log_info "[2/3] --help sur les scripts utilisateur..."

HELP_TARGETS_COMMON=("scripts/lint.sh")

case "$TARGET_OS" in
  linux)
    HELP_TARGETS=(
      "${HELP_TARGETS_COMMON[@]}"
      "linux/install.sh"
      "linux/install_powerline.sh"
      "linux/install_terminal.sh"
      "linux/install_profile.sh"
      "linux/uninstall.sh"
      "linux/purge_zsh.sh"
    )
    ;;
  macos)
    HELP_TARGETS=(
      "${HELP_TARGETS_COMMON[@]}"
      "macos/install.sh"
      "macos/install_powerline.sh"
      "macos/install_terminal.sh"
      "macos/install_profile.sh"
      "macos/uninstall.sh"
      "macos/purge_zsh.sh"
    )
    ;;
  *)
    log_warn "OS $TARGET_OS non supporté pour --help — étape 2 ignorée."
    HELP_TARGETS=()
    ;;
esac

for target in ${HELP_TARGETS[@]+"${HELP_TARGETS[@]}"}; do
  if [[ ! -f "${REPO_ROOT}/${target}" ]]; then
    log_warn "SKIP  --help $target (fichier absent)"
    continue
  fi
  run_test "--help $target" bash "${REPO_ROOT}/${target}" --help
done

# --- 3) --dry-run --yes sur purge/uninstall ----------------------------------
if [[ "$SKIP_DRY_RUN" -eq 1 ]]; then
  log_info "[3/3] --dry-run --yes SKIPPED (--skip-dry-run)"
else
  log_info "[3/3] --dry-run --yes sur purge/uninstall..."
  case "$TARGET_OS" in
    linux)
      DRY_TARGETS=(
        "linux/purge_zsh.sh"
        "linux/uninstall.sh"
      )
      ;;
    macos)
      DRY_TARGETS=(
        "macos/purge_zsh.sh"
        "macos/uninstall.sh"
      )
      ;;
    *)
      log_warn "OS $TARGET_OS non supporté pour --dry-run — étape 3 ignorée."
      DRY_TARGETS=()
      ;;
  esac
  for target in ${DRY_TARGETS[@]+"${DRY_TARGETS[@]}"}; do
    if [[ ! -f "${REPO_ROOT}/${target}" ]]; then continue; fi
    run_test "--dry-run --yes $target" bash "${REPO_ROOT}/${target}" --dry-run --yes
  done
fi

echo ""
if [[ "$failures" -eq 0 ]]; then
  log_ok "Smoke Bash : $total tests, 0 échec."
  exit "$LUCKY_EXIT_OK"
else
  log_error "Smoke Bash : $failures échec(s) sur $total tests."
  exit "$LUCKY_EXIT_GENERIC"
fi
