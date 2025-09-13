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

include(${CMAKE_CURRENT_LIST_DIR}/PowerShell.cmake)

#[[====================================================================================================================
    add_clang_format
    ----------------
    Adds a 'clang-format' target to run clang-format.exe on all *.h, *.cpp files under ${CMAKE_SOURCE_DIR}.

====================================================================================================================]]#
function(add_clang_format)
    windowscmake_find_powershell(POWERSHELL_PATH)

    if(CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
        cmake_path(GET CMAKE_CXX_COMPILER PARENT_PATH CLANG_TOOLING_PATH)
        set(CLANG_FORMAT_PATH "${CLANG_TOOLING_PATH}/clang-format")
    elseif(CMAKE_C_COMPILER_ID STREQUAL "Clang")
        cmake_path(GET CMAKE_C_COMPILER PARENT_PATH CLANG_TOOLING_PATH)
        set(CLANG_FORMAT_PATH "${CLANG_TOOLING_PATH}/clang-format")
    else()
        find_program(CLANG_FORMAT_PATH
            NAMES
                clang-format
                clang-format.exe
            HINTS
                "${VS_INSTALLATION_PATH}/VC/Tools/Llvm/x64/bin"
                "$ENV{ProgramFiles}/LLVM/bin"
            REQUIRED
        )
    endif()

    if(NOT (DEFINED CLANG_FORMAT_FILE_EXTENSIONS))
        set(CLANG_FORMAT_FILE_EXTENSIONS ${CMAKE_CXX_SOURCE_FILE_EXTENSIONS})
        list(APPEND CLANG_FORMAT_FILE_EXTENSIONS ${CMAKE_C_SOURCE_FILE_EXTENSIONS})
        list(APPEND CLANG_FORMAT_FILE_EXTENSIONS h H hpp HPP hxx HXX)
    endif()

    list(TRANSFORM CLANG_FORMAT_FILE_EXTENSIONS PREPEND "*.")
    list(JOIN CLANG_FORMAT_FILE_EXTENSIONS " " CLANG_FORMAT_WILDCARDS)

    set(CLANG_FORMAT_COMMAND "              \
git ls-files ${CLANG_FORMAT_WILDCARDS} |    \
    ForEach-Object -Parallel {              \
        & '${CLANG_FORMAT_PATH}' -i $$_     \
    }                                       \
")
    set(POWERSHELL_COMMAND ${POWERSHELL_PATH} -ExecutionPolicy RemoteSigned -NoProfile -NonInteractive -Command ${CLANG_FORMAT_COMMAND})

    add_custom_target(clang-format
        COMMAND ${POWERSHELL_COMMAND}
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        COMMENT "clang-format'ing"
    )
endfunction()

add_clang_format()
