# ----------------------------------------------------------------------------------------------------------------------
# MIT License
#
# Copyright (c) 2025 Mark Schofield
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
# ----------------------------------------------------------------------------------------------------------------------
cmake_minimum_required(VERSION 3.20)

include_guard()

#[[====================================================================================================================
    windowscmake_add_asan_target
    ----------------------------
    Adds a 'WindowsCMakeAsan' target.

    To enable ASAN:
        1. Specify 'WindowsCMakeAsan' as a 'target_link_library' of the target to enable.
        2. Specify 'WindowsCMakeAsan' as a 'link_library' of a scope to enable for all targets in that scope. To
            opt-out a target set the 'ENABLE_ASAN' target property to 'OFF'.
====================================================================================================================]] #
function(windowscmake_add_asan_target)
    add_library(WindowsCMakeAsanRuntime SHARED IMPORTED)

    target_compile_options(WindowsCMakeAsanRuntime
        INTERFACE
            $<$<OR:$<CXX_COMPILER_FRONTEND_VARIANT:MSVC>,$<C_COMPILER_FRONTEND_VARIANT:MSVC>>:/fsanitize=address>
            $<$<OR:$<CXX_COMPILER_FRONTEND_VARIANT:GNU>,$<C_COMPILER_FRONTEND_VARIANT:GNU>>:-fsanitize=address>
    )

    if(CMAKE_SYSTEM_PROCESSOR STREQUAL AMD64)
        set(ASAN_PLATFORM x86_64)
    else()
        set(ASAN_PLATFORM i386)
    endif()

    # When specifying the ASAN_DLL_PATH, the DLL is available in the _host_ architecture folder for the architecture
    # being targeted - as a result `Host${CMAKE_VS_PLATFORM_TOOLSET_ARCHITECTURE}` is used, and *not*
    # `Host${CMAKE_VS_PLATFORM_TOOLSET_HOST_ARCHITECTURE}`
    set(ASAN_LIB_PATH "${VS_TOOLSET_PATH}/lib/${CMAKE_VS_PLATFORM_TOOLSET_ARCHITECTURE}")
    set(ASAN_DLL_PATH "${VS_TOOLSET_PATH}/bin/Host${CMAKE_VS_PLATFORM_TOOLSET_ARCHITECTURE}/${CMAKE_VS_PLATFORM_TOOLSET_ARCHITECTURE}")

    if((CMAKE_CXX_COMPILER_ID STREQUAL "MSVC") OR (CMAKE_C_COMPILER_ID STREQUAL "MSVC"))
        set(ASAN_LIB "${ASAN_LIB_PATH}/VCAsan.lib")
        set(ASAN_LIB_DEBUG "${ASAN_LIB_PATH}/VCAsanD.lib")

        set(ASAN_DLL "${ASAN_DLL_PATH}/clang_rt.asan_dynamic-${ASAN_PLATFORM}.dll")
        set(ASAN_DLL_DEBUG ${ASAN_DLL})

        set(ASAN_EXTRA_LIB "legacy_stdio_wide_specifiers.lib")
    elseif((CMAKE_CXX_COMPILER_ID STREQUAL "Clang") OR (CMAKE_C_COMPILER_ID STREQUAL "Clang"))
        set(ASAN_LIB "${ASAN_LIB_PATH}/clang_rt.asan_dynamic-${ASAN_PLATFORM}.lib")
        set(ASAN_LIB_DEBUG "${ASAN_LIB_PATH}/clang_rt.asan_dbg_dynamic-${ASAN_PLATFORM}.lib")

        set(ASAN_DLL "${ASAN_DLL_PATH}/clang_rt.asan_dynamic-${ASAN_PLATFORM}.dll")
        set(ASAN_DLL_DEBUG "${ASAN_DLL_PATH}/clang_rt.asan_dbg_dynamic-${ASAN_PLATFORM}.dll")

        set(ASAN_EXTRA_LIB clang_rt.asan_dynamic_runtime_thunk-x86_64.lib)
    else()
        message(FATAL_ERROR "Unsupported compiler: CMAKE_CXX_COMPILER_ID = ${CMAKE_CXX_COMPILER_ID}")
    endif()

    set_target_properties(WindowsCMakeAsanRuntime
        PROPERTIES
            FOLDER WindowsCMake

            IMPORTED_IMPLIB_DEBUG ${ASAN_LIB_DEBUG}
            IMPORTED_IMPLIB_RELEASE ${ASAN_LIB}
            IMPORTED_IMPLIB_RELWITHDEBINFO ${ASAN_LIB}
            IMPORTED_IMPLIB_RELMINSIZE ${ASAN_LIB}

            IMPORTED_LOCATION_DEBUG ${ASAN_DLL_DEBUG}
            IMPORTED_LOCATION_RELEASE ${ASAN_DLL}
            IMPORTED_LOCATION_RELWITHDEBINFO ${ASAN_DLL}
            IMPORTED_LOCATION_RELMINSIZE ${ASAN_DLL}
    )

    target_link_libraries(WindowsCMakeAsanRuntime
        INTERFACE
            ${ASAN_EXTRA_LIB}
    )

    target_link_options(WindowsCMakeAsanRuntime
        INTERFACE
           $<$<OR:$<CXX_COMPILER_FRONTEND_VARIANT:MSVC>,$<C_COMPILER_FRONTEND_VARIANT:MSVC>>:/INCREMENTAL:NO>
    )

    add_library(WindowsCMakeAsan INTERFACE)
    target_link_libraries(WindowsCMakeAsan
        INTERFACE
            $<$<NOT:$<STREQUAL:$<TARGET_PROPERTY:ENABLE_ASAN>,OFF>>:WindowsCMakeAsanRuntime>
    )
endfunction()

windowscmake_add_asan_target()
