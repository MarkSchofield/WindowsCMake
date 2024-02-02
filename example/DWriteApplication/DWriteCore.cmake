#----------------------------------------------------------------------------------------------------------------------
# MIT License
#
# Copyright (c) 2021 Mark Schofield
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#----------------------------------------------------------------------------------------------------------------------
include_guard()

cmake_minimum_required(VERSION 3.21)

include(${WINDOWSCMAKE_DIR}/NuGet.cmake)

# Install the Microsoft.WindowsAppSDK NuGet
install_nuget_package(Microsoft.WindowsAppSDK 1.4.231219000 NUGET_MICROSOFT_WINDOWSAPPSDK
    PACKAGESAVEMODE nuspec
    PRERELEASE ON
)

#
#
#
add_library(WindowsAppRuntime_Initializer OBJECT
    ${NUGET_MICROSOFT_WINDOWSAPPSDK}/include/MddBootstrapAutoInitializer.cpp
)

target_compile_features(WindowsAppRuntime_Initializer
    PRIVATE
        cxx_std_17
)

target_include_directories(WindowsAppRuntime_Initializer
    PRIVATE
        ${NUGET_MICROSOFT_WINDOWSAPPSDK}/include
)

#
#
#
add_library(WindowsAppRuntime_Bootstrap SHARED IMPORTED)

set_target_properties(WindowsAppRuntime_Bootstrap
    PROPERTIES
        IMPORTED_IMPLIB "${NUGET_MICROSOFT_WINDOWSAPPSDK}/lib/win10-x64/Microsoft.WindowsAppRuntime.Bootstrap.lib"
        IMPORTED_LOCATION "${NUGET_MICROSOFT_WINDOWSAPPSDK}/runtimes/win10-x64/native/Microsoft.WindowsAppRuntime.Bootstrap.dll"
)

#
#
#
add_library(WindowsAppRuntime INTERFACE)

file(READ "${NUGET_MICROSOFT_WINDOWSAPPSDK}/WindowsAppSDK-VersionInfo.json" WINDOWSAPPSDK_VERSIONINFO)

string(JSON WINDOWSAPPSDK_RELEASE_MAJOR GET ${WINDOWSAPPSDK_VERSIONINFO} Release Major)
string(JSON WINDOWSAPPSDK_RELEASE_MINOR GET ${WINDOWSAPPSDK_VERSIONINFO} Release Minor)
string(JSON WINDOWSAPPSDK_RELEASE_MAJORMINOR GET ${WINDOWSAPPSDK_VERSIONINFO} Release MajorMinor HexUInt32)
string(JSON WINDOWSAPPSDK_RELEASE_VERSION_TAG GET ${WINDOWSAPPSDK_VERSIONINFO} Release VersionTag)
string(JSON WINDOWSAPPSDK_RELEASE_CHANNEL GET ${WINDOWSAPPSDK_VERSIONINFO} Release Channel)

set_target_properties(WindowsAppRuntime
    PROPERTIES
        WINDOWSAPPSDK_RELEASE_MAJOR ${WINDOWSAPPSDK_RELEASE_MAJOR}
        WINDOWSAPPSDK_RELEASE_MINOR ${WINDOWSAPPSDK_RELEASE_MINOR}
        WINDOWSAPPSDK_RELEASE_MAJORMINOR ${WINDOWSAPPSDK_RELEASE_MAJORMINOR}
        WINDOWSAPPSDK_RELEASE_VERSION_TAG "${WINDOWSAPPSDK_RELEASE_VERSION_TAG}"
        WINDOWSAPPSDK_RELEASE_CHANNEL "${WINDOWSAPPSDK_RELEASE_CHANNEL}"
        WINDOWSAPPSDK_LIB "${NUGET_MICROSOFT_WINDOWSAPPSDK}/lib/win10-x64"
)

target_link_libraries(WindowsAppRuntime
    INTERFACE
        WindowsAppRuntime_Bootstrap
        $<TARGET_OBJECTS:WindowsAppRuntime_Initializer>
)

target_include_directories(WindowsAppRuntime
    INTERFACE
        ${NUGET_MICROSOFT_WINDOWSAPPSDK}/include
)

#
#
#
add_library(DWriteCore SHARED IMPORTED)

target_link_libraries(DWriteCore
    INTERFACE
        WindowsAppRuntime
        delayimp.lib
)

target_link_options(DWriteCore
    INTERFACE
        /DELAYLOAD:DWriteCore.dll
)

set_target_properties(DWriteCore
    PROPERTIES
        IMPORTED_IMPLIB "${NUGET_MICROSOFT_WINDOWSAPPSDK}/lib/win10-x64/DWriteCore.lib"
)
