#!/usr/bin/env bash
set -eou pipefail
# shellcheck disable=SC2086

# Usage: $0 [-h] [-t] [-v] [host]
#  -h             Display this help message.
#  -t             Enable trace mode (adds --show-trace flag).
#  -v             Enable verbose/debug output.
#  host           Host name; if not provided, defaults to the output of hostname.

usage() {
	echo "Usage: $0 [-h] [-t] [-v] [host]"
	exit 1
}

# Logging functions with timestamps
timestamp() {
	date '+%Y-%m-%d %H:%M:%S'
}

log_red() {
	echo -e "\x1B[31m[!] $1\x1B[0m"
}

log_green() {
	echo -e "\x1B[32m[+] $1\x1B[0m"
}

log_yellow() {
	echo -e "\x1B[33m[*] $1\x1B[0m"
}

log_debug() {
	if [ "${VERBOSE}" = "true" ]; then
		echo -e "\x1B[34m[$(timestamp)] [DEBUG] $1\x1B[0m"
	fi
}

# Check if a command exists
command_exists() {
	command -v "$1" &>/dev/null
}

# Default configuration values
TRACE="false"
VERBOSE="false"

# Parse options using getopts
while getopts "htv" opt; do
	case "$opt" in
	h) usage ;;
	t) TRACE="true" ;;
	v) VERBOSE="true" ;;
	*) usage ;;
	esac
done
shift $((OPTIND - 1))

# Set host (defaults to the output of hostname)
HOST="${1:-$(hostname)}"

# Build switch arguments for nix commands
switch_args=""
if [ "${TRACE}" = "true" ]; then
	switch_args+="--show-trace "
fi
switch_args+="--impure --flake .#${HOST} switch"

# OS-specific rebuild function for Darwin
rebuild_darwin() {
	log_debug "Starting Darwin rebuild"
	mkdir -p "${HOME}/.config/nix"
	local CONF="${HOME}/.config/nix/nix.conf"
	if [ ! -f "${CONF}" ]; then
		cat <<-EOF >"${CONF}"
			            experimental-features = nix-command flakes
		EOF
	fi

	# Ensure git is installed for tagging/version control
	if ! command_exists git; then
		log_green "Installing Xcode tools..."
		xcode-select --install || {
			log_red "xcode-select installation failed"
			return 1
		}
	fi

	log_green "====== REBUILD ======"
	if ! command_exists darwin-rebuild; then
		log_debug "darwin-rebuild not found; using 'nix run nix-darwin'"
		nix run nix-darwin -- switch ${switch_args} --impure
	else
		log_debug "Using darwin-rebuild with arguments: ${switch_args}"
		darwin-rebuild ${switch_args}
	fi
}

# OS-specific rebuild function for Linux (or non‑Darwin)
rebuild_linux() {
	log_debug "Starting Linux rebuild"
	log_green "====== REBUILD ======"
	if command_exists nh; then
		log_debug "Using nh command for rebuild"
		nh os switch . -- --impure --show-trace
	else
		log_debug "Using sudo nixos-rebuild with arguments: ${switch_args}"
		sudo nixos-rebuild ${switch_args}
	fi
}

# Execute the rebuild command
if [ "$(uname -s)" == "Darwin" ]; then
	rebuild_darwin
else
	rebuild_linux
fi

log_green "====== POST‑REBUILD ======"
log_green "Rebuilt successfully"

# Check for pending git changes before tagging the commit as buildable.
if git diff --exit-code >/dev/null && git diff --staged --exit-code >/dev/null; then
	if git tag --points-at HEAD | grep -q buildable; then
		log_yellow "Current commit is already tagged as buildable"
	else
		git tag buildable-"$(date +%Y%m%d%H%M%S)" -m ''
		log_green "Tagged current commit as buildable"
	fi
else
	log_yellow "WARN: There are pending changes that could affect the build. Commit them before tagging."
fi
