#----------------------------------------------------------------------------------------------------------------------
#
#----------------------------------------------------------------------------------------------------------------------
cmake_minimum_required(VERSION 3.20)

project(WindowsCMakeExample)

include(${WINDOWSCMAKE_DIR}/CppWinRT.cmake)

add_cppwinrt_projection(CppWinRT
    INPUTS
        ${CMAKE_SYSTEM_VERSION}
    OPTIMIZE
)

add_compile_definitions(
    UNICODE
    _UNICODE
)

add_subdirectory(CommandLine)
add_subdirectory(SharedLibrary)
add_subdirectory(WindowsApplication)

if((CMAKE_CXX_COMPILER_FRONTEND_VARIANT STREQUAL "MSVC")
    AND (NOT (CMAKE_SYSTEM_PROCESSOR STREQUAL x86))
    AND (CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
    AND (CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL "17.0"))
    add_subdirectory(CommandLineImportLibrary)
endif()

if(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
    if((CMAKE_SYSTEM_PROCESSOR STREQUAL x64) OR (CMAKE_SYSTEM_PROCESSOR STREQUAL AMD64) OR (CMAKE_SYSTEM_PROCESSOR STREQUAL x86))
        add_subdirectory(CommandLineModule)
    endif()
endif()

if((CMAKE_CXX_COMPILER_FRONTEND_VARIANT STREQUAL "MSVC"))
    add_subdirectory(CommandLineWinRT)
    add_subdirectory(RuntimeComponent)
endif()
