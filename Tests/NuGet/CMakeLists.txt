cmake_minimum_required(VERSION 3.20)

include(${WINDOWSCMAKE_DIR}/Ninja.cmake)
include(${WINDOWSCMAKE_DIR}/NuGet.cmake)

project(WindowsCMakeTests)

if (NOT SPECIFIED_PACKAGESAVEMODE)
    set(SPECIFIED_PACKAGESAVEMODE nupkg)
endif()

if(NOT SKIP_NUGET_DOWNLOAD)
    install_nuget_package(Humanizer.Core 2.14.1 NUGET_HUMANIZER_CORE
        PACKAGESAVEMODE ${SPECIFIED_PACKAGESAVEMODE}
    )
endif()
