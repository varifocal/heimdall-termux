#!/data/data/com.termux/files/usr/bin/bash
set -eu

cd "$(dirname "$0")/.."

pkg install -y cmake clang make libusb zlib pkg-config

mkdir -p build
cd build
cmake -DDISABLE_FRONTEND=ON -DCMAKE_BUILD_TYPE=Release ..
make -j"$(nproc)"

echo "Built build/bin/heimdall"
