# ----------------------------------------------------------------------------------------------------------------------
#
# ----------------------------------------------------------------------------------------------------------------------

if(CMAKE_SYSTEM_PROCESSOR STREQUAL AMD64)
    set(RUNTIME_IDENTIFIER x64)
elseif(CMAKE_SYSTEM_PROCESSOR STREQUAL ARM64)
    set(RUNTIME_IDENTIFIER arm64)
elseif(CMAKE_SYSTEM_PROCESSOR STREQUAL X86)
    set(RUNTIME_IDENTIFIER x86)
else()
    message(FATAL_ERROR "Unable to identify the runtime identifier from CMAKE_SYSTEM_PROCESSOR ${CMAKE_SYSTEM_PROCESSOR}")
endif()


# Add the 'Microsoft.Web.WebView2.Core' target
#
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

# Add the 'Microsoft.WindowsAppRuntime' and 'Microsoft.WindowsAppSDK' targets
#
install_nuget_package(Microsoft.WindowsAppSDK 1.6.241114003 NUGET_MICROSOFT_WINDOWSAPPSDK
    PACKAGESAVEMODE nuspec
)

add_library(Microsoft.WindowsAppRuntime SHARED IMPORTED)

set_target_properties(Microsoft.WindowsAppRuntime PROPERTIES
    IMPORTED_IMPLIB ${NUGET_MICROSOFT_WINDOWSAPPSDK}/lib/win10-${RUNTIME_IDENTIFIER}/Microsoft.WindowsAppRuntime.Bootstrap.lib
    IMPORTED_LOCATION ${NUGET_MICROSOFT_WINDOWSAPPSDK}/runtimes/win-${RUNTIME_IDENTIFIER}/native/Microsoft.WindowsAppRuntime.Bootstrap.dll
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

target_include_directories(Microsoft.WindowsAppSDK
    INTERFACE
        ${NUGET_MICROSOFT_WINDOWSAPPSDK}/include
)

target_link_libraries(Microsoft.WindowsAppSDK
    INTERFACE
        Microsoft.WindowsAppRuntime
)
