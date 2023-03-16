# ----------------------------------------------------------------------------------------------------------------------
#
# ----------------------------------------------------------------------------------------------------------------------
project(WinUIApplication LANGUAGES CXX)

install_nuget_package(Microsoft.Web.WebView2 1.0.2651.64 NUGET_MICROSOFT_WEB_WEBVIEW2
    PACKAGESAVEMODE nuspec
)

add_cppwinrt_projection(Microsoft.Web.WebView2.Core
    INPUTS
        ${NUGET_MICROSOFT_WEB_WEBVIEW2}/lib/Microsoft.Web.WebView2.Core.winmd
    DEPS
        CppWinRT
    OPTIMIZE
)

install_nuget_package(Microsoft.WindowsAppSDK 1.6.241114003 NUGET_MICROSOFT_WINDOWSAPPSDK
    PACKAGESAVEMODE nuspec
)

add_cppwinrt_projection(Microsoft.WindowsAppSDK
    INPUTS
        ${NUGET_MICROSOFT_WINDOWSAPPSDK}/lib/uap10.0/Microsoft.UI.Text.winmd
        ${NUGET_MICROSOFT_WINDOWSAPPSDK}/lib/uap10.0/Microsoft.UI.Xaml.winmd
        ${NUGET_MICROSOFT_WINDOWSAPPSDK}/lib/uap10.0/Microsoft.Windows.ApplicationModel.DynamicDependency.winmd
        ${NUGET_MICROSOFT_WINDOWSAPPSDK}/lib/uap10.0/Microsoft.Windows.ApplicationModel.Resources.winmd
        ${NUGET_MICROSOFT_WINDOWSAPPSDK}/lib/uap10.0/Microsoft.Windows.ApplicationModel.WindowsAppRuntime.winmd
        ${NUGET_MICROSOFT_WINDOWSAPPSDK}/lib/uap10.0/Microsoft.Windows.AppLifecycle.winmd
        ${NUGET_MICROSOFT_WINDOWSAPPSDK}/lib/uap10.0/Microsoft.Windows.AppNotifications.Builder.winmd
        ${NUGET_MICROSOFT_WINDOWSAPPSDK}/lib/uap10.0/Microsoft.Windows.AppNotifications.winmd
        ${NUGET_MICROSOFT_WINDOWSAPPSDK}/lib/uap10.0/Microsoft.Windows.Globalization.winmd
        ${NUGET_MICROSOFT_WINDOWSAPPSDK}/lib/uap10.0/Microsoft.Windows.Management.Deployment.winmd
        ${NUGET_MICROSOFT_WINDOWSAPPSDK}/lib/uap10.0/Microsoft.Windows.PushNotifications.winmd
        ${NUGET_MICROSOFT_WINDOWSAPPSDK}/lib/uap10.0/Microsoft.Windows.Security.AccessControl.winmd
        ${NUGET_MICROSOFT_WINDOWSAPPSDK}/lib/uap10.0/Microsoft.Windows.Storage.winmd
        ${NUGET_MICROSOFT_WINDOWSAPPSDK}/lib/uap10.0/Microsoft.Windows.System.Power.winmd
        ${NUGET_MICROSOFT_WINDOWSAPPSDK}/lib/uap10.0/Microsoft.Windows.System.winmd
        ${NUGET_MICROSOFT_WINDOWSAPPSDK}/lib/uap10.0/Microsoft.Windows.Widgets.winmd
        ${NUGET_MICROSOFT_WINDOWSAPPSDK}/lib/uap10.0.18362/Microsoft.Foundation.winmd
        ${NUGET_MICROSOFT_WINDOWSAPPSDK}/lib/uap10.0.18362/Microsoft.Graphics.winmd
        ${NUGET_MICROSOFT_WINDOWSAPPSDK}/lib/uap10.0.18362/Microsoft.UI.winmd
    DEPS
        CppWinRT
        Microsoft.Web.WebView2.Core
    OPTIMIZE
)

add_executable(WinUIApplication WIN32
    WinUIApplication.exe.manifest
    WinUIApplication.cpp
    WinUIApplication.rc
)

target_compile_features(WinUIApplication
    PRIVATE
        cxx_std_20
)

target_include_directories(WinUIApplication
    PRIVATE
        ${NUGET_MICROSOFT_WINDOWSAPPSDK}/include
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
