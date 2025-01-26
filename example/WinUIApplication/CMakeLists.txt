# ----------------------------------------------------------------------------------------------------------------------
#
# ----------------------------------------------------------------------------------------------------------------------
project(WinUIApplication LANGUAGES CXX)

include(Dependencies.cmake)

add_executable(WinUIApplication WIN32
    WinUIApplication.exe.manifest
    WinUIApplication.cpp
    WinUIApplication.rc
)

target_compile_features(WinUIApplication
    PRIVATE
        cxx_std_20
)

target_precompile_headers(WinUIApplication
    PRIVATE
        framework.h
)

target_link_libraries(WinUIApplication
    PRIVATE
        wil
        Microsoft.WindowsAppSDK
        OneCoreUAP.lib
)

set_source_files_properties(WinUIApplication.rc
    PROPERTIES
    OBJECT_DEPENDS "${CMAKE_CURRENT_LIST_DIR}/small.ico;${CMAKE_CURRENT_LIST_DIR}/WinUIApplication.ico"
)

add_custom_command(TARGET WinUIApplication POST_BUILD
    COMMAND "${CMAKE_COMMAND};-E;$<IF:$<BOOL:$<TARGET_RUNTIME_DLLS:WinUIApplication>>,copy;$<TARGET_RUNTIME_DLLS:WinUIApplication>;$<TARGET_FILE_DIR:WinUIApplication>,true>"
    COMMAND_EXPAND_LISTS
    COMMENT "Copying runtime dependencies"
)
