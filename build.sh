
if [ ! -d build ]; then
  mkdir build
fi

cd build

if [ ! -d SceLibcExt_stub ]; then
  vita-libs-gen-2 -yml=../SceLibcExt/exports.yml -output=./SceLibcExt_stub -cmake=true
  if [ $? -ne 0 ]; then
    exit 1
  fi

  cd SceLibcExt_stub
  cmake .
  make -j$(nproc)
  cd ..
fi

cmake ..
if [ $? -ne 0 ]; then
  exit 1
fi

make -j$(nproc)
