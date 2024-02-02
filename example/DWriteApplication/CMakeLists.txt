#----------------------------------------------------------------------------------------------------------------------
#
#----------------------------------------------------------------------------------------------------------------------
project(DWriteApplication LANGUAGES CXX)

include(DWriteCore.cmake)

add_executable(DWriteApplication WIN32
    DWriteApplication.cpp
    DWriteApplication.rc
)

set_source_files_properties(DWriteApplication.rc
    PROPERTIES
        OBJECT_DEPENDS "${CMAKE_CURRENT_LIST_DIR}/small.ico;${CMAKE_CURRENT_LIST_DIR}/DWriteApplication.ico"
)

target_compile_features(DWriteApplication
    PRIVATE
        cxx_std_20
)

target_link_libraries(DWriteApplication
    PUBLIC
        DWriteCore
)

add_custom_command(TARGET DWriteApplication POST_BUILD
    COMMENT Copying 'DWriteApplication' dependencies
    COMMAND ${CMAKE_COMMAND} -E copy $<TARGET_RUNTIME_DLLS:DWriteApplication> $<TARGET_FILE_DIR:DWriteApplication>
    COMMAND_EXPAND_LISTS
)
