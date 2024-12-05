#----------------------------------------------------------------------------------------------------------------------
# MIT License
#
# Copyright (c) 2024 Mark Schofield
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
cmake_minimum_required(VERSION 3.20)

set(MAKEAPPX_TOOL "${WINDOWS_KITS_BIN_PATH}/${CMAKE_VS_PLATFORM_TOOLSET_HOST_ARCHITECTURE}/makeappx.exe")

#[[====================================================================================================================
====================================================================================================================]]#
function(add_msix_package TARGET)
    set(OPTIONS)
    set(ONE_VALUE_KEYWORDS MANIFEST FILE)
    set(MULTI_VALUE_KEYWORDS CONTENTS)

    cmake_parse_arguments(PARSE_ARGV 0 MSIX_PACKAGE "${OPTIONS}" "${ONE_VALUE_KEYWORDS}" "${MULTI_VALUE_KEYWORDS}")

    set(APPX_MAPFILE_PATH "${PROJECT_BINARY_DIR}/$<CONFIG>/Packages/${TARGET}.mapfile")

    add_custom_target(${TARGET}
        DEPENDS ${MSIX_PACKAGE_FILE}
        COMMENT "Generating ${MSIX_PACKAGE_FILE}"
    )

    # Convert the 'CONTENTS' values to a list of entries for the map file.
    unset(MAPFILE_ENTRIES)
    unset(MAPFILE_DEPENDENCIES)
    while(MSIX_PACKAGE_CONTENTS)
        list(POP_FRONT MSIX_PACKAGE_CONTENTS MAPFILE_ENTRY_SOURCE)
        list(POP_FRONT MSIX_PACKAGE_CONTENTS MAPFILE_ENTRY_TARGET_FOLDER)

        if(TARGET ${MAPFILE_ENTRY_SOURCE})
            # It's a target
            add_dependencies(${TARGET} ${MAPFILE_ENTRY_SOURCE})
            list(APPEND MAPFILE_DEPENDENCIES $<TARGET_FILE:${MAPFILE_ENTRY_SOURCE}>)
            list(APPEND MAPFILE_ENTRIES "\"$<TARGET_FILE:${MAPFILE_ENTRY_SOURCE}>\" \"$<TARGET_FILE_NAME:${MAPFILE_ENTRY_SOURCE}>\"")
        else()
            # It's a file
            get_filename_component(MAPFILE_ENTRY_SOURCE_FILE ${MAPFILE_ENTRY_SOURCE} NAME)
            list(APPEND MAPFILE_DEPENDENCIES ${CMAKE_CURRENT_SOURCE_DIR}/${MAPFILE_ENTRY_SOURCE})
            list(APPEND MAPFILE_ENTRIES "\"${CMAKE_CURRENT_SOURCE_DIR}/${MAPFILE_ENTRY_SOURCE}\" \"${MAPFILE_ENTRY_TARGET_FOLDER}/${MAPFILE_ENTRY_SOURCE_FILE}\"")
        endif()
    endwhile()

    # Add the 'MANIFEST' value to the MAPFILE_ENTRIES
    list(APPEND MAPFILE_ENTRIES "\"${MSIX_PACKAGE_MANIFEST}\" \"AppxManifest.xml\"")

    list(JOIN MAPFILE_ENTRIES "\r\n" MAPFILE_ENTRIES_TEXT)

    file(GENERATE
        OUTPUT ${APPX_MAPFILE_PATH}
        CONTENT "\
[Files]
${MAPFILE_ENTRIES_TEXT}
"
        NEWLINE_STYLE CRLF
)

    set(MAKEAPPX_COMMAND "\"${MAKEAPPX_TOOL}\"")
    list(APPEND MAKEAPPX_COMMAND "pack")
    list(APPEND MAKEAPPX_COMMAND "/p ${MSIX_PACKAGE_FILE}")
    list(APPEND MAKEAPPX_COMMAND "/f ${APPX_MAPFILE_PATH}")
    list(APPEND MAKEAPPX_COMMAND "/overwrite")

    list(JOIN MAKEAPPX_COMMAND " " MAKEAPPX_COMMAND_LINE)
    set(MAKEAPPX_COMMAND_SCRIPT ${CMAKE_CURRENT_BINARY_DIR}/$<CONFIG>/make_appx.cmd)
    file(GENERATE OUTPUT ${MAKEAPPX_COMMAND_SCRIPT} CONTENT "\
@echo off
${MAKEAPPX_COMMAND_LINE}
")

    add_custom_command(
        OUTPUT ${MSIX_PACKAGE_FILE}
        COMMAND ${MAKEAPPX_COMMAND_SCRIPT}
        DEPENDS ${MSIX_PACKAGE_MANIFEST} ${MAPFILE_DEPENDENCIES}
    )
endfunction()
