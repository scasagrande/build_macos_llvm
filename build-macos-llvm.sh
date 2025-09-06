#!/usr/bin/env bash

set -eux

LLVM_PROJ_DIR=/tmp/llvm-project-$1
LLVM_TAG="llvmorg-$1"
OUTPUT_PATH="$2"
ORIG_DIR="$PWD"

rm -rf "$LLVM_PROJ_DIR"
git clone https://github.com/llvm/llvm-project.git --branch "$LLVM_TAG" --depth 1 "$LLVM_PROJ_DIR"
cp update-DistributionExample.cmake.patch "$LLVM_PROJ_DIR"

cd "$LLVM_PROJ_DIR"

git apply update-DistributionExample.cmake.patch

mkdir build && cd build
cmake -DCMAKE_INSTALL_PREFIX=../install -G Ninja -C ../clang/cmake/caches/DistributionExample.cmake ../llvm
ninja stage2-distribution
ninja stage2-install-distribution

cd "${LLVM_PROJ_DIR}/install/bin"
ln -s llvm-ar llvm-ranlib

cd "${LLVM_PROJ_DIR}/install"
tar -cf output.tar bin include lib
zstd --rm --ultra -T0 -22 output.tar

cd "$ORIG_DIR"
mv "${LLVM_PROJ_DIR}/install/output.tar.zst" "${OUTPUT_PATH}"

