#----------------------------------------------------------------------------------------------------------------------
# MIT License
#
# Copyright (c) 2026 Mark Schofield
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

if(CMAKE_VERSION VERSION_LESS 3.20)
    message(FATAL_ERROR "WindowsCMake requires at least CMake 3.20, but CMake ${CMAKE_VERSION} is in use.")
endif()

# The WindowsCMake::ConsoleAllocationPolicy target will:
#   * add the 'ConsoleAllocationPolicy.manifest'
#   * link with the /MANIFEST linker option
#
# for consumers of this target that have TYPE set to EXECUTABLE.
add_library(WindowsCMake.ConsoleAllocationPolicy INTERFACE)
add_library(WindowsCMake::ConsoleAllocationPolicy ALIAS WindowsCMake.ConsoleAllocationPolicy)

target_sources(WindowsCMake.ConsoleAllocationPolicy
    INTERFACE
        $<$<STREQUAL:$<TARGET_PROPERTY:TYPE>,EXECUTABLE>:${CMAKE_CURRENT_LIST_DIR}/ConsoleAllocationPolicy.manifest>
)

target_link_options(WindowsCMake.ConsoleAllocationPolicy
    INTERFACE
        LINKER:$<$<STREQUAL:$<TARGET_PROPERTY:TYPE>,EXECUTABLE>:/MANIFEST>
)
