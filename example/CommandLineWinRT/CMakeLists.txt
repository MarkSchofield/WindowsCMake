#----------------------------------------------------------------------------------------------------------------------
#
#----------------------------------------------------------------------------------------------------------------------
project(CommandLineWinRT LANGUAGES CXX)

add_executable(CommandLineWinRT
    main.cpp
)

target_compile_features(CommandLineWinRT
    PRIVATE
        cxx_std_20
)

target_precompile_headers(CommandLineWinRT
    PRIVATE
        pch.h
)

target_link_libraries(CommandLineWinRT
    PRIVATE
        RuntimeComponentCppWinRT
)

# Add a 'post build' step to copy 'TARGET_RUNTIME_DLLS' into the 'TARGET_FILE_DIR'.
post_build_copy_runtime_dlls(CommandLineWinRT)
