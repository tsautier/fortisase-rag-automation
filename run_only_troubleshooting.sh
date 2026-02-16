#!/usr/bin/env bash
set -Eeuo pipefail

# ===== Configuration =====
# You can override AUTO_APPROVE via env var when invoking:
#   AUTO_APPROVE=true|false ./run_tf_menu.sh
# Action (apply/destroy/plan) is selected via an initial menu and can be changed later.
AUTO_APPROVE="${AUTO_APPROVE:-true}" # ignored if ACTION=plan

# Dynamic state
ACTION=""      # apply | destroy | plan
CMD=()         # computed from ACTION and AUTO_APPROVE

# ===== Targets grouped by module =====
# These will be populated dynamically by discover_terraform_resources()

# Networking: Private Access + hosts + host groups
NETWORKING_TARGETS=()

# Security: policies, profiles, and the Marketing user group
SECURITY_TARGETS=()

# Endpoint: endpoint_* and ztna_* resources
ENDPOINT_TARGETS=()

# Auth: SAML server
AUTH_TARGETS=()

# ===== Terraform Resource Discovery =====
discover_terraform_resources() {
  # Parse all .tf files and extract resources with their module and resource name
  # Format: resource "type" "name" { ... }
  # Pattern: module.MODULE_NAME.RESOURCE_TYPE.RESOURCE_NAME
  
  local module
  local resource_type
  local resource_name
  
  for tf_file in modules/**/*.tf main.tf; do
    [[ ! -f "$tf_file" ]] && continue
    
    # Extract module name from path (e.g., modules/auth/auth.tf -> auth)
    if [[ "$tf_file" =~ modules/([^/]+)/ ]]; then
      module="${BASH_REMATCH[1]}"
    else
      # Skip root-level files for now
      continue
    fi
    
    # Extract all resource declarations from the file
    # Pattern: resource "type" "name"
    while IFS= read -r line; do
      if [[ "$line" =~ ^resource[[:space:]]+\"([^\"]+)\"[[:space:]]+\"([^\"]+)\" ]]; then
        resource_type="${BASH_REMATCH[1]}"
        resource_name="${BASH_REMATCH[2]}"
        local target="module.${module}.${resource_type}.${resource_name}"
        
        # Add to appropriate array based on module name
        case "$module" in
          auth)
            AUTH_TARGETS+=("$target")
            ;;
          endpoint)
            ENDPOINT_TARGETS+=("$target")
            ;;
          security)
            SECURITY_TARGETS+=("$target")
            ;;
          networking)
            NETWORKING_TARGETS+=("$target")
            ;;
        esac
      fi
    done < "$tf_file"
  done
}

# ===== UI helpers =====
red()    { printf "\033[31m%s\033[0m\n" "$*"; }
green()  { printf "\033[32m%s\033[0m\n" "$*"; }
cyan()   { printf "\033[36m%s\033[0m\n" "$*"; }
bold()   { printf "\033[1m%s\033[0m\n" "$*"; }
yellow() { printf "\033[33m%s\033[0m\n" "$*"; }

pause()  { read -rp "Press Enter to continue..." _; }

cleanup() { echo; cyan "Exiting..."; }
trap cleanup EXIT

require_terraform() {
  if ! command -v terraform >/dev/null 2>&1; then
    red "Terraform is not installed or not in PATH."
    exit 1
  fi
}

set_cmd_from_action() {
  CMD=(terraform "${ACTION}")
  if [[ "${ACTION}" != "plan" && "${AUTO_APPROVE}" == "true" ]]; then
    CMD+=("-auto-approve")
  fi
}

choose_action_menu() {
  while true; do
    echo
    bold "Choose action:"
    PS3="$(cyan 'Select (1-4): ')"
    local options=("apply" "destroy" "plan")
    select opt in "${options[@]}"; do
      case "$REPLY" in
        1) ACTION="apply"; set_cmd_from_action; return ;;
        2) ACTION="destroy"; set_cmd_from_action; return ;;
        3) ACTION="plan"; set_cmd_from_action; return ;;
        *) echo "Invalid option." ;;
      esac
    done
  done
}

ensure_action_selected() {
  if [[ -z "${ACTION}" ]]; then
    choose_action_menu
    if [[ -z "${ACTION}" ]]; then
      red "No action selected. Exiting."
      exit 1
    fi
  fi
}

run_global() {
  local module="$1"
  bold "→ Running ${ACTION} for module '${module}' (global)"
  echo
  set -x
  "${CMD[@]}" -target="module.${module}"
  { set +x; } 2>/dev/null
  echo
  green "Done: ${ACTION} module.${module}"
  pause
}

run_by_resource() {
    local module="$1"; shift || true
    local -n arr_ref="$1"  # nameref to the module's targets array
    if (( ${#arr_ref[@]} == 0 )); then
        yellow "No granular targets defined for '${module}'."
        pause
        return
    fi
    bold "→ Resource-by-resource for '${module}' (action: ${ACTION})"
    echo
    for target in "${arr_ref[@]}"; do
        set -x
        "${CMD[@]}" -target="${target}"
        { set +x; } 2>/dev/null
        echo "OK: ${target}"
    done
    echo
    green "Completed resource-by-resource for '${module}'"
    pause
  if (( ${#arr_ref[@]} == 0 )); then
    yellow "No granular targets defined for '${module}'."
    pause
    return
  fi
}

module_action_menu() {
  local module="$1"; shift
  local targets_array_name="$1"

  while true; do
    echo
    bold "Module selected: ${module}   |   Action: ${ACTION}"
    PS3="$(cyan 'Choose mode (1-4): ')"
    local options=("Global (module.${module})" "Resource by resource" "Change action")
    select opt in "${options[@]}"; do
      case "$REPLY" in
        1) run_global "${module}"; return ;;           # return to main menu after run
        2) run_by_resource "${module}" "${targets_array_name}"; return ;;  # return to main menu after run
        3) choose_action_menu; break ;;  # stay in this menu after changing action
        4) return ;;                     # go back to main menu
        *) echo "Invalid option." ;;
      esac
    done
  done
}

print_discovered_resources() {
  local module
  
  echo
  bold "=== Discovered Terraform Resources ==="
  echo
  
  for module in networking security endpoint auth; do
    local array_name="${module^^}_TARGETS[@]"
    local targets=("${!array_name}")
    
    echo
    bold "${module^^} (${#targets[@]} resources):"
    if (( ${#targets[@]} == 0 )); then
      yellow "  No resources discovered"
    else
      for i in "${!targets[@]}"; do
        echo "  $(( i + 1 )). ${targets[$i]}"
      done
    fi
  done
  
  echo
  pause
}

main_menu() {
  while true; do
    ensure_action_selected
    echo
    bold "Terraform Menu — ACTION=${ACTION^^} | auto-approve=${AUTO_APPROVE}"
    PS3="$(cyan 'Choose a module (1-7): ')"
    local options=("Networking" "Security" "Endpoint" "Auth" "Print discovered resources" "Change action" "Exit")
    COLUMNS=1
    select opt in "${options[@]}"; do
      case "$REPLY" in
        1) module_action_menu "networking" NETWORKING_TARGETS; break ;;
        2) module_action_menu "security"   SECURITY_TARGETS;   break ;;
        3) module_action_menu "endpoint"   ENDPOINT_TARGETS;   break ;;
        4) module_action_menu "auth"       AUTH_TARGETS;       break ;;
        5) print_discovered_resources; break ;;
        6) choose_action_menu; break ;;
        7) return ;;
        *) echo "Invalid option." ;;
      esac
    done
  done
}

# ===== Entry point =====
require_terraform
cyan "Discovering Terraform resources..."
discover_terraform_resources
green "Resource discovery complete."
echo
main_menu