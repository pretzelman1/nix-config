#!/usr/bin/env bash

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
	echo -e "\x1B[31m[$(timestamp)] [!] $1\x1B[0m"
}

log_green() {
	echo -e "\x1B[32m[$(timestamp)] [+] $1\x1B[0m"
}

log_yellow() {
	echo -e "\x1B[33m[$(timestamp)] [*] $1\x1B[0m"
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

# Ensure unbuffer is installed
if ! command_exists unbuffer; then
	log_red "unbuffer is not installed. Please install it (usually via the expect package) and try again."
	exit 1
fi

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
		unbuffer nix run nix-darwin -- switch ${switch_args} --impure
		return $?
	else
		log_debug "Using darwin-rebuild with arguments: ${switch_args}"
		unbuffer darwin-rebuild ${switch_args}
		return $?
	fi
}

# OS-specific rebuild function for Linux (or non‑Darwin)
rebuild_linux() {
	log_debug "Starting Linux rebuild"
	log_green "====== REBUILD ======"
	if command_exists nh; then
		log_debug "Using nh command for rebuild"
		unbuffer nh os switch . -- --impure --show-trace
		return $?
	else
		log_debug "Using sudo nixos-rebuild with arguments: ${switch_args}"
		unbuffer sudo nixos-rebuild ${switch_args}
		return $?
	fi
}

# Create a temporary file to capture output
temp_file=$(mktemp)

# Execute the rebuild command and tee its output to both stdout and the temporary file.
if [ "$(uname -s)" == "Darwin" ]; then
	rebuild_darwin 2>&1 | tee "$temp_file"
	cmd_exit=${PIPESTATUS[0]}
else
	rebuild_linux 2>&1 | tee "$temp_file"
	cmd_exit=${PIPESTATUS[0]}
fi

# Read the captured output for further parsing.
rebuild_output=$(cat "$temp_file")
rm "$temp_file"

# If the rebuild command failed, extract and format the error context.
if [ $cmd_exit -ne 0 ]; then
	error_context=$(echo "$rebuild_output" | awk '
    /hosts\/|home\// {
        print "Error: " prev;
        print "Location:";
        orig_line = $0;
        loc_line = $0;
        # Remove the leading "at " from the location line
        sub(/^[ \t]*at /, "", loc_line);
        print loc_line;
        for (i = 1; i <= 4; i++) {
            if (getline line) {
                print line;
            }
        }
        if (match(orig_line, /at ([^:]+):/, arr)) {
            file_path = arr[1];
            # Remove the /nix/store/<hash>-source/ prefix
            gsub(/^\/nix\/store\/[^-]+-[^\/]+\//, "", file_path);
            print "File: " file_path;
        }
        exit
    }
    { prev = $0 }
    ')

	# Fancy formatting using figlet and lolcat if available
	if [ -n "$error_context" ]; then
		if command_exists figlet; then
			figlet "ERROR DETECTED"
		fi
		if command_exists lolcat; then
			echo "$error_context" | lolcat
		else
			echo "$error_context"
		fi
	else
		log_red "Rebuild command failed with exit code $cmd_exit, but no relevant error context was detected."
	fi

	log_red "Rebuild command failed with exit code $cmd_exit."
	exit $cmd_exit
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
