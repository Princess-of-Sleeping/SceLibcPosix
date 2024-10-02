cmake_minimum_required(VERSION 3.7)

if(NOT DEFINED CMAKE_TOOLCHAIN_FILE)
  if(DEFINED ENV{VITASDK})
    set(CMAKE_TOOLCHAIN_FILE "$ENV{VITASDK}/share/vita.toolchain.cmake" CACHE PATH "toolchain file")
  else()
    message(FATAL_ERROR "Please define VITASDK to point to your SDK path!")
  endif()
endif()

project(libSceLibcPosix)
include("$ENV{VITASDK}/share/vita.cmake" REQUIRED)

file(GLOB_RECURSE sources *.c)

add_executable(SceLibcPosix $<TARGET_OBJECTS:crt0_module>
  ${sources}
)

target_compile_options(SceLibcPosix PRIVATE -fno-lto)

target_include_directories(SceLibcPosix PRIVATE ../include include internal)

target_link_libraries(SceLibcPosix PRIVATE
  SceRtc_stub
  SceNetCtl_stub_weak
  SceNet_stub_weak
  SceProcessmgr_stub
  SceSysmodule_stub
  SceKernelThreadMgr_stub
  SceIofilemgr_stub
  SceFios2_stub_weak
  ${CMAKE_BINARY_DIR}/SceLibcExt_stub/libSceLibcExt_stub_weak.a
  SceLibKernel_stub
  SceRtabi_stub
)

set_target_properties(SceLibcPosix
  PROPERTIES LINK_FLAGS "-nostdlib"
  COMPILE_FLAGS "-D__PSP2_USER__"
)

vita_create_self(libc_posix.suprx SceLibcPosix PRIVATE
  CONFIG exports.yml
  UNSAFE
  STRIPPED
  REL_OPTIMIZE
)

vita_create_stubs(stubs SceLibcPosix ${CMAKE_CURRENT_SOURCE_DIR}/exports.yml)

install(DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/stubs/
  DESTINATION lib
  FILES_MATCHING PATTERN "*.a"
)

install(FILES ${CMAKE_BINARY_DIR}/SceLibcExt/libSceLibcExt_stub.a
  ${CMAKE_BINARY_DIR}/SceLibcExt/libSceLibcExt_stub_weak.a
  DESTINATION lib
)

install(FILES ${CMAKE_CURRENT_BINARY_DIR}/SceLibcPosix.suprx
  DESTINATION "$ENV{VITASDK}/arm-vita-eabi/modules"
)
