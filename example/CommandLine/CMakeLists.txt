#----------------------------------------------------------------------------------------------------------------------
#
#----------------------------------------------------------------------------------------------------------------------
project(CommandLine LANGUAGES CXX)

add_executable(CommandLine
    main.cpp
)

# Add a 'post build' step to copy 'TARGET_RUNTIME_DLLS' into the 'TARGET_FILE_DIR'.
post_build_copy_runtime_dlls(CommandLine)
