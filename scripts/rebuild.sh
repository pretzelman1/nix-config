#!/usr/bin/env bash
# shellcheck disable=SC2086
#
# This script is used to rebuild the system configuration for the current host.
#
# SC2086 is ignored because we purposefully pass some values as a set of arguments,
# so we want the splitting to happen

function red() {
	echo -e "\x1B[31m[!] $1 \x1B[0m"
	if [ -n "${2-}" ]; then
		echo -e "\x1B[31m[!] $($2) \x1B[0m"
	fi
}
function green() {
	echo -e "\x1B[32m[+] $1 \x1B[0m"
	if [ -n "${2-}" ]; then
		echo -e "\x1B[32m[+] $($2) \x1B[0m"
	fi
}
function yellow() {
	echo -e "\x1B[33m[*] $1 \x1B[0m"
	if [ -n "${2-}" ]; then
		echo -e "\x1B[33m[*] $($2) \x1B[0m"
	fi
}

switch_args="--show-trace --impure --flake "
if [[ -n $1 && $1 == "trace" ]]; then
	switch_args="$switch_args --show-trace "
elif [[ -n $1 ]]; then
	HOST=$1
else
	HOST=$(hostname)
fi
switch_args="$switch_args .#$HOST switch"

# Create a temporary file to capture command output
tmpfile=$(mktemp)

os=$(uname -s)
if [ "$os" == "Darwin" ]; then
	# Darwin-specific setup
	mkdir -p ~/.config/nix || true
	CONF=~/.config/nix/nix.conf
	if [ ! -f $CONF ]; then
		# Enable nix-command and flakes to bootstrap
		cat <<-EOF >$CONF
			            experimental-features = nix-command flakes
		EOF
	fi

	# Install Xcode tools if git is missing
	if ! which git &>/dev/null; then
		echo "Installing xcode tools"
		xcode-select --install
	fi

	green "====== REBUILD ======"
	if ! which darwin-rebuild &>/dev/null; then
		unbuffer nix run nix-darwin -- switch --show-trace --flake .#"$HOST" --impure 2>&1 | tee "$tmpfile"
		cmd_exit=${PIPESTATUS[0]}
	else
		unbuffer darwin-rebuild $switch_args 2>&1 | tee "$tmpfile"
		cmd_exit=${PIPESTATUS[0]}
	fi
else
	green "====== REBUILD ======"
	if command -v nh &>/dev/null; then
		unbuffer nh os switch . -- --impure --show-trace 2>&1 | tee "$tmpfile"
		cmd_exit=${PIPESTATUS[0]}
	else
		unbuffer sudo nixos-rebuild $switch_args 2>&1 | tee "$tmpfile"
		cmd_exit=${PIPESTATUS[0]}
	fi
fi

# Check the last 10 lines of the rebuild output for the word "error" (case-insensitive)
if tail -n 10 "$tmpfile" | grep -i error >/dev/null; then
	red "Build output contains errors in the last 10 lines"
	rm "$tmpfile"
	exit 1
fi

rm "$tmpfile"

# Proceed with post-rebuild actions if the command succeeded.
if [ $cmd_exit -eq 0 ]; then
	green "====== POST-REBUILD ======"
	green "Rebuilt successfully"

	# Check if there are any pending changes that would affect the build succeeding.
	if git diff --exit-code >/dev/null && git diff --staged --exit-code >/dev/null; then
		if git tag --points-at HEAD | grep -q buildable; then
			yellow "Current commit is already tagged as buildable"
		else
			git tag buildable-"$(date +%Y%m%d%H%M%S)" -m ''
			green "Tagged current commit as buildable"
		fi
	else
		yellow "WARN: There are pending changes that would affect the build succeeding. Commit them before tagging"
	fi
fi
