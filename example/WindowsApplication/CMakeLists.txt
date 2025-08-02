#----------------------------------------------------------------------------------------------------------------------
#
#----------------------------------------------------------------------------------------------------------------------
project(WindowsApplication LANGUAGES CXX)

add_executable(WindowsApplication WIN32
    WindowsApplication.cpp
    WindowsApplication.rc
)

set_source_files_properties(WindowsApplication.rc
    PROPERTIES
        OBJECT_DEPENDS "${CMAKE_CURRENT_LIST_DIR}/small.ico;${CMAKE_CURRENT_LIST_DIR}/WindowsApplication.ico"
)

# Add a 'post build' step to copy 'TARGET_RUNTIME_DLLS' into the 'TARGET_FILE_DIR'.
post_build_copy_runtime_dlls(WindowsApplication)
