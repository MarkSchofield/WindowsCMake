#----------------------------------------------------------------------------------------------------------------------
#
#----------------------------------------------------------------------------------------------------------------------
cmake_minimum_required(VERSION 3.20)

project(WindowsCMakeExample)

include(${WINDOWSCMAKE_DIR}/CppWinRT.cmake)

add_cppwinrt_projection(CppWinRT
    INPUTS
        nuget:${CPPWINRT_PROJECTION_NUGET_VERSION}
    OPTIMIZE
)

add_compile_definitions(
    UNICODE
    _UNICODE
)

# Add 'IMPORTED' libraries for NuGet dependencies.
#
include(${WINDOWSCMAKE_DIR}/NuGet.cmake)
install_nuget_package("Microsoft.Windows.ImplementationLibrary" "1.0.240803.1" NUGET_MICROSOFT_WINDOWS_IMPLEMENTATIONLIBRARY)

add_library(wil INTERFACE IMPORTED)

target_include_directories(wil
    INTERFACE
        ${NUGET_MICROSOFT_WINDOWS_IMPLEMENTATIONLIBRARY}/include
)

add_subdirectory(CommandLine)
add_subdirectory(SharedLibrary)
add_subdirectory(WindowsApplication)

if(((CMAKE_CXX_COMPILER_ID STREQUAL "MSVC") AND (NOT (CMAKE_SYSTEM_PROCESSOR STREQUAL X86))) OR
    ((CMAKE_CXX_COMPILER_ID STREQUAL "Clang") AND
        (CMAKE_CXX_COMPILER_FRONTEND_VARIANT STREQUAL "MSVC") AND
        (CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL "17.0")))
    add_subdirectory(CommandLineImportLibrary)
endif()

if((CMAKE_CXX_COMPILER_FRONTEND_VARIANT STREQUAL "MSVC"))
    add_subdirectory(CommandLineWinRT)
    add_subdirectory(RuntimeComponent)
    add_subdirectory(WinUIApplication)
endif()
