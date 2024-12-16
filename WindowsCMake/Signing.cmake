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

include_guard()

include(${WINDOWSCMAKE_DIR}/PowerShell.cmake)

set(MAKECERT_TOOL "${WINDOWS_KITS_BIN_PATH}/${CMAKE_VS_PLATFORM_TOOLSET_ARCHITECTURE}/MakeCert.exe")
set(PVK2PFX_TOOL "${WINDOWS_KITS_BIN_PATH}/${CMAKE_VS_PLATFORM_TOOLSET_ARCHITECTURE}/pvk2pfx.exe")

##++FIXTHIS
## This is taken from Windows.MSVC.toolchain, but would be handy on the clang-side, too.
if(CMAKE_SYSTEM_PROCESSOR STREQUAL AMD64)
    set(CMAKE_VS_PLATFORM_TOOLSET_ARCHITECTURE x64)
elseif((CMAKE_SYSTEM_PROCESSOR STREQUAL ARM)
    OR (CMAKE_SYSTEM_PROCESSOR STREQUAL ARM64)
    OR (CMAKE_SYSTEM_PROCESSOR STREQUAL X86))
    set(CMAKE_VS_PLATFORM_TOOLSET_ARCHITECTURE ${CMAKE_SYSTEM_PROCESSOR})
else()
    message(FATAL_ERROR "Unable identify compiler architecture for CMAKE_SYSTEM_PROCESSOR ${CMAKE_SYSTEM_PROCESSOR}")
endif()
##--FIXTHIS

#[[====================================================================================================================

====================================================================================================================]]#
function(create_certificate)
    set(OPTIONS)
    set(ONE_VALUE_KEYWORDS SUBJECT FRIENDLY_NAME OUTPUT_THUMBPRINT)
    set(MULTI_VALUE_KEYWORDS)

    cmake_parse_arguments(PARSE_ARGV 0 CREATE "${OPTIONS}" "${ONE_VALUE_KEYWORDS}" "${MULTI_VALUE_KEYWORDS}")

    set(CREATE_SCRIPT "$Parameters = @{")
    string(APPEND CREATE_SCRIPT "  CertStoreLocation = 'Cert:/CurrentUser/My'\n")
    string(APPEND CREATE_SCRIPT "  Subject = \"${CREATE_SUBJECT}\"\n")
    string(APPEND CREATE_SCRIPT "  KeyUsage = 'DigitalSignature'\n")
    string(APPEND CREATE_SCRIPT "  KeyFriendlyName = '${CREATE_FRIENDLY_NAME}'\n")
    string(APPEND CREATE_SCRIPT "  TextExtension = @('2.5.29.37={text}1.3.6.1.5.5.7.3.3','2.5.29.19={text}')\n")
    string(APPEND CREATE_SCRIPT "}\n")
    string(APPEND CREATE_SCRIPT "New-SelfSignedCertificate @Parameters |")
    string(APPEND CREATE_SCRIPT "  Select-Object -ExpandProperty Thumbprint")

    execute_powershell(
        ${CREATE_SCRIPT}
        OUTPUT_VARIABLE THUMBPRINT
        RESULT_VARIABLE POWERSHELL_RESULT
    )

    if((POWERSHELL_RESULT) OR (NOT THUMBPRINT))
        message(FATAL_ERROR "Unable to create a certificate.")
    endif()

    set(${CREATE_OUTPUT_THUMBPRINT} "${THUMBPRINT}" PARENT_SCOPE)
endfunction()

#[[====================================================================================================================

====================================================================================================================]]#
function(find_certificate)
    set(OPTIONS)
    set(ONE_VALUE_KEYWORDS SUBJECT FRIENDLY_NAME OUTPUT_THUMBPRINT)
    set(MULTI_VALUE_KEYWORDS)

    cmake_parse_arguments(PARSE_ARGV 0 FIND "${OPTIONS}" "${ONE_VALUE_KEYWORDS}" "${MULTI_VALUE_KEYWORDS}")

    set(FIND_SCRIPT "Get-ChildItem Cert:/CurrentUser/My | ")
    string(APPEND FIND_SCRIPT "Where-Object { $_.EnhancedKeyUsageList.ObjectId -eq '1.3.6.1.5.5.7.3.3' } | ")

    if(FIND_FRIENDLY_NAME)
        string(APPEND FIND_SCRIPT "Where-Object { $_.FriendlyName -eq '${FIND_FRIENDLY_NAME}' } | ")
    endif()

    if(FIND_SUBJECT)
        string(APPEND FIND_SCRIPT "Where-Object { $_.Subject -eq '${FIND_SUBJECT}' } | ")
    endif()

    string(APPEND FIND_SCRIPT "Select-Object -ExpandProperty Thumbprint")

    execute_powershell(
        ${FIND_SCRIPT}
        OUTPUT_VARIABLE THUMBPRINT
        RESULT_VARIABLE POWERSHELL_RESULT
    )
    if(POWERSHELL_RESULT)
        message(FATAL_ERROR "Unable to find a suitable certificate.")
    endif()

    set(${FIND_OUTPUT_THUMBPRINT} "${THUMBPRINT}" PARENT_SCOPE)
endfunction()

#[[====================================================================================================================
====================================================================================================================]]#
function(sign TARGET)
    set(OPTIONS)
    set(ONE_VALUE_KEYWORDS HASHALGORITHM PASSWORD PFX INPUT OUTPUT SUBJECT THUMBPRINT)
    set(MULTI_VALUE_KEYWORDS)

    set(SIGN_HASHALGORITHM sha256)
    set(SIGN_PASSWORD "")

    cmake_parse_arguments(PARSE_ARGV 0 SIGN "${OPTIONS}" "${ONE_VALUE_KEYWORDS}" "${MULTI_VALUE_KEYWORDS}")

    set(SIGNTOOL_TOOL "${WINDOWS_KITS_BIN_PATH}/${CMAKE_VS_PLATFORM_TOOLSET_ARCHITECTURE}/signtool.exe")
    set(SIGNTOOL_COMMAND "\"${SIGNTOOL_TOOL}\"")
    list(APPEND SIGNTOOL_COMMAND "sign")
    list(APPEND SIGNTOOL_COMMAND "/fd ${SIGN_HASHALGORITHM}")
    list(APPEND SIGNTOOL_COMMAND "/a")

    if(SIGN_PFX)
        list(APPEND SIGNTOOL_COMMAND "/f ${SIGN_PFX}")
    endif()

    if(SIGN_SUBJECT)
        list(APPEND SIGNTOOL_COMMAND "/n ${SIGN_SUBJECT}")
    endif()

    if(SIGN_THUMBPRINT)
        list(APPEND SIGNTOOL_COMMAND "/sha1 ${SIGN_THUMBPRINT}")
    endif()

    list(APPEND SIGNTOOL_COMMAND "${SIGN_OUTPUT}")

    list(JOIN SIGNTOOL_COMMAND " " SIGNTOOL_COMMAND_LINE)
    set(SIGNTOOL_COMMAND_SCRIPT ${CMAKE_CURRENT_BINARY_DIR}/$<CONFIG>/sign_${TARGET}.cmd)
    file(GENERATE OUTPUT ${SIGNTOOL_COMMAND_SCRIPT} CONTENT "\
@echo off
${SIGNTOOL_COMMAND_LINE}
")

    message(VERBOSE "sign: SIGNTOOL_COMMAND_SCRIPT = ${SIGNTOOL_COMMAND_SCRIPT}")

    add_custom_command(
        OUTPUT ${SIGN_OUTPUT}
        COMMAND ${CMAKE_COMMAND} -E copy ${SIGN_INPUT} ${SIGN_OUTPUT}
        COMMAND ${SIGNTOOL_COMMAND_SCRIPT}
        DEPENDS  ${SIGN_INPUT}
    )

    add_custom_target(${TARGET}
        DEPENDS ${SIGN_OUTPUT}
    )
endfunction()
