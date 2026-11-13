#!/data/data/com.termux/files/usr/bin/bash
set -eu

if [ -z "${PREFIX:-}" ] || [ "$(uname -o)" != "Android" ]; then
	echo "This installer must run inside Termux." >&2
	exit 1
fi

tarball=${1:-heimdall-termux-aarch64.tar.gz}
if [ ! -f "$tarball" ]; then
	echo "Tarball not found: $tarball" >&2
	echo "Usage: bash install.sh [heimdall-termux-aarch64.tar.gz]" >&2
	exit 1
fi

pkg install -y libusb jq termux-api

stage=$(mktemp -d)
tar -xzf "$tarball" -C "$stage"

install -D -m 700 "$stage/heimdall-real" "$PREFIX/libexec/heimdall-real"
install -D -m 700 "$stage/heimdall" "$PREFIX/bin/heimdall"

"$PREFIX/libexec/heimdall-real" version
echo "Installed $PREFIX/bin/heimdall"
