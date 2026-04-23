#!/usr/bin/env bash
# scripts/_common.sh — Helpers partagés pour les scripts Bash Lucky Terminal.
#
# À dot-sourcer depuis un script :
#   SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
#   . "${SCRIPT_DIR}/../scripts/_common.sh"
#
# Compatible Bash 3.2 (macOS) : pas de ${var,,}, pas d'associative arrays,
# pas de `mapfile`/`readarray`.
#
# Pendant Bash de windows/_common.ps1 pour PowerShell.

# --- Garde d'inclusion : évite les ré-exécutions multiples. ---
if [[ "${LUCKY_COMMON_LOADED:-0}" -eq 1 ]]; then
  return 0 2>/dev/null || true
fi
LUCKY_COMMON_LOADED=1

# --- Codes de sortie (convention projet) ---------------------------------
# Utilisés par `die`, par les scripts appelant, et par la CI pour diagnostic.
# 0-9  : cas normaux
# 10+  : interactions utilisateur (refus, annulation)
# 20+  : pré-conditions système (OS, permissions)
readonly LUCKY_EXIT_OK=0
readonly LUCKY_EXIT_GENERIC=1           # erreur générique non classée
readonly LUCKY_EXIT_MISSING_TOOL=2      # commande/dépendance absente
readonly LUCKY_EXIT_USAGE=3             # mauvais usage CLI
readonly LUCKY_EXIT_CANCELLED=10        # refus utilisateur (confirm répondu non)
readonly LUCKY_EXIT_UNSUPPORTED_OS=20   # OS / plateforme non prise en charge
readonly LUCKY_EXIT_MISSING_FILE=21     # fichier attendu absent du dépôt

# --- Couleurs (activées si stderr est un TTY et NO_COLOR non défini) ----
if [[ -t 2 ]] && [[ -z "${NO_COLOR:-}" ]]; then
  _LK_COL_RESET=$'\033[0m'
  _LK_COL_INFO=$'\033[36m'   # cyan
  _LK_COL_OK=$'\033[32m'     # green
  _LK_COL_WARN=$'\033[33m'   # yellow
  _LK_COL_ERROR=$'\033[31m'  # red
else
  _LK_COL_RESET=''
  _LK_COL_INFO=''
  _LK_COL_OK=''
  _LK_COL_WARN=''
  _LK_COL_ERROR=''
fi

# --- Logs standardisés ---------------------------------------------------
log_info() { printf '%s[INFO]%s  %s\n' "$_LK_COL_INFO" "$_LK_COL_RESET" "$*"; }
log_ok() { printf '%s[OK]%s    %s\n' "$_LK_COL_OK" "$_LK_COL_RESET" "$*"; }
log_warn() { printf '%s[WARN]%s  %s\n' "$_LK_COL_WARN" "$_LK_COL_RESET" "$*" >&2; }
log_error() { printf '%s[ERROR]%s %s\n' "$_LK_COL_ERROR" "$_LK_COL_RESET" "$*" >&2; }

# --- Erreur fatale -------------------------------------------------------
# Usage : die "Message"              # exit LUCKY_EXIT_GENERIC
#         die "Message" 2            # exit avec code personnalisé
die() {
  local rc="${2:-$LUCKY_EXIT_GENERIC}"
  log_error "$1"
  exit "$rc"
}

# --- Vérification d'outils ----------------------------------------------
# Usage : require_cmd git
#         require_cmd dconf "apt install dconf-cli"
require_cmd() {
  local cmd="$1"
  local hint="${2:-}"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    if [[ -n "$hint" ]]; then
      die "Commande requise introuvable : '$cmd'. Installation : $hint" "$LUCKY_EXIT_MISSING_TOOL"
    else
      die "Commande requise introuvable : '$cmd'" "$LUCKY_EXIT_MISSING_TOOL"
    fi
  fi
}

# --- Conversion minuscule (compat Bash 3.2) -----------------------------
_sh_tolower() {
  printf '%s' "$1" | tr '[:upper:]' '[:lower:]'
}

# --- Détection OS ---------------------------------------------------------
# Retourne : "linux", "macos", ou "unknown".
lucky_os() {
  case "$(uname -s)" in
    Darwin) echo "macos" ;;
    Linux) echo "linux" ;;
    *) echo "unknown" ;;
  esac
}

# --- Confirmations interactives -----------------------------------------
# Bypass non-interactif : LUCKY_AUTO_YES=1 (mis par --yes via parse_common_args).
# Retour : 0 = oui, 1 = non.
confirm() {
  local msg="$1"
  if [[ "${LUCKY_AUTO_YES:-0}" -eq 1 ]]; then
    log_info "OK (mode --yes) : $msg"
    return 0
  fi
  local reply=""
  read -r -p "$msg [o/N] " reply
  local lc
  lc="$(_sh_tolower "$reply")"
  [[ "$lc" == "o" || "$lc" == "oui" || "$lc" == "y" || "$lc" == "yes" ]]
}

# --- Parsing des options communes ---------------------------------------
# Reconnaît : -y/--yes, -v/--verbose, --dry-run, -h/--help (à gérer par le script).
# Les arguments non consommés sont stockés dans LUCKY_REMAINING_ARGS (array).
#
# Usage :
#   parse_common_args "$@"
#   set -- "${LUCKY_REMAINING_ARGS[@]}"    # restaure $@ avec les args restants
LUCKY_AUTO_YES=0
LUCKY_VERBOSE=0
LUCKY_DRY_RUN=0
LUCKY_REMAINING_ARGS=()

parse_common_args() {
  LUCKY_REMAINING_ARGS=()
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -y | --yes) LUCKY_AUTO_YES=1 ;;
      -v | --verbose) LUCKY_VERBOSE=1 ;;
      --dry-run) LUCKY_DRY_RUN=1 ;;
      *) LUCKY_REMAINING_ARGS+=("$1") ;;
    esac
    shift
  done
}

# --- Wrapper dry-run -----------------------------------------------------
# Usage : lucky_run rm -rf "$HOME/.foo"
# En mode --dry-run, affiche la commande au lieu de l'exécuter.
lucky_run() {
  if [[ "${LUCKY_DRY_RUN:-0}" -eq 1 ]]; then
    log_info "[dry-run] $*"
    return 0
  fi
  "$@"
}
