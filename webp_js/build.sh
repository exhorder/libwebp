#/bin/bash
#----------------------------------------------------------------------------------------------
# Build script for webp.js
# Based on https://github.com/webmproject/libwebp/blob/master/README.webp_js
# Run from parent folder as 'cd webp_js && ./build.sh'
#----------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------
# Suitable to compile under MSYS + Emscripten
#----------------------------------------------------------------------------------------------
# $ make -v
# GNU Make 3.81
# Copyright (C) 2006  Free Software Foundation, Inc.
# This is free software; see the source for copying conditions.
# There is NO warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# This program built for i686-pc-msys
#----------------------------------------------------------------------------------------------
# $ cmake --version
# cmake version 3.11.3
#----------------------------------------------------------------------------------------------
# $ uname -a
# MSYS_NT-6.3 DC 2.10.0(0.325/5/3) 2018-04-23 03:21 x86_64 Msys
#----------------------------------------------------------------------------------------------
# $ emcc -v
# emcc (Emscripten gcc/clang-like replacement + linker emulating GNU ld) 1.37.21
# clang version 4.0.0  (emscripten 1.37.21 : 1.37.21)
# Target: x86_64-pc-windows-msvc
# Thread model: posix
# InstalledDir: C:\emsdk\clang\e1.37.21_64bit
# INFO:root:(Emscripten: Running sanity checks)
#----------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------
#

[[ "$1" = "clean" ]] && mv webp.js .webp.js

if [ -f "Makefile" ]; then
    make clean
fi
rm -rf CMake* src *.cmake *.mem *.wasm *.txt Makefile

if [ "$1" = "clean" ]; then
    mv .webp.js webp.js
    exit 0
fi

cmake -DWEBP_BUILD_WEBP_JS=ON \
    -DEMSCRIPTEN_GENERATE_BITCODE_STATIC_LIBRARIES=1 \
    -DCMAKE_TOOLCHAIN_FILE=$EMSCRIPTEN/cmake/Modules/Platform/Emscripten.cmake \
    -G "MSYS Makefiles" ../

grep emcc -rl --exclude=*.sh | xargs sed -i 's/\.bat//g'

sed -i 's/-O2/-O3 --llvm-lto 3/g' CMakeCache.txt

make
sed -i 's/INVOKE_RUN=0/& -s NO_EXIT_RUNTIME=1 -s NO_DYNAMIC_EXECUTION=1 -s DISABLE_EXCEPTION_CATCHING=1 --memory-init-file 0/g' ./CMakeFiles/webp_js.dir/build.make
sed -i 's/libwebpdecoder.bc/& libwebpdemux.bc/' ./CMakeFiles/webp_js.dir/linklibs.rsp
rm webp.js
make

sed 's!^!// !' ../COPYING > webp.jsx
cat pre.js webp.js post.js >> webp.jsx
mv webp.jsx webp.js
dos2unix webp.js

start index.html
