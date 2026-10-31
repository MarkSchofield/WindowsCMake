#----------------------------------------------------------------------------------------------------------------------
#
#----------------------------------------------------------------------------------------------------------------------
project(Hybrid LANGUAGES CXX)

add_executable(Hybrid
    main.cpp
)

target_link_libraries(Hybrid
    PRIVATE
        WindowsCMake::ConsoleAllocationPolicy
)

# Add a 'post build' step to copy 'TARGET_RUNTIME_DLLS' into the 'TARGET_FILE_DIR'.
post_build_copy_runtime_dlls(Hybrid)
