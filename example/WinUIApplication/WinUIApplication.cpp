#include "Resource.h"

// clang-format off
#include <Windows.h>
#include <winrt/base.h>
// clang-format on

#include <WindowsAppSDK-VersionInfo.h>
#include <appmodel.h>
#include <iostream>
#include <wil/resource.h>
#include <wil/result_macros.h>

#undef GetCurrentTime

#include <winrt/Microsoft.UI.Xaml.Controls.Primitives.h>
#include <winrt/Microsoft.UI.Xaml.Controls.h>
#include <winrt/Microsoft.UI.Xaml.Markup.h>
#include <winrt/Microsoft.UI.Xaml.XamlTypeInfo.h>
#include <winrt/Windows.Foundation.Collections.h>
#include <winrt/Windows.UI.Xaml.Interop.h>

using namespace winrt::Microsoft::UI::Xaml;
using namespace winrt::Microsoft::UI::Xaml::Controls;
using namespace winrt::Microsoft::UI::Xaml::XamlTypeInfo;
using namespace winrt::Microsoft::UI::Xaml::Markup;
using namespace winrt::Windows::UI::Xaml::Interop;

class App : public ApplicationT<App, IXamlMetadataProvider>
{
public:
    void OnLaunched(const LaunchActivatedEventArgs&)
    {
        Resources().MergedDictionaries().Append(XamlControlsResources());

        window = Window();

        StackPanel stackPanel;
        stackPanel.HorizontalAlignment(HorizontalAlignment::Center);
        stackPanel.VerticalAlignment(VerticalAlignment::Center);

        Button button;
        button.Content(winrt::box_value(L"WinUI 3 in CMake!"));

        window.Content(stackPanel);
        stackPanel.Children().Append(button);

        window.Activate();
    }

    IXamlType GetXamlType(const TypeName& type)
    {
        return provider.GetXamlType(type);
    }

    IXamlType GetXamlType(const winrt::hstring& fullname)
    {
        return provider.GetXamlType(fullname);
    }

    winrt::com_array<XmlnsDefinition> GetXmlnsDefinitions()
    {
        return provider.GetXmlnsDefinitions();
    }

private:
    Window window{nullptr};
    XamlControlsXamlMetaDataProvider provider;
};

inline constexpr PACKAGE_VERSION PackageVersion(USHORT major, USHORT minor, USHORT build = 0, USHORT revision = 0)
{
    PACKAGE_VERSION packageVersion{};

    packageVersion.Major = major;
    packageVersion.Minor = minor;
    packageVersion.Build = build;
    packageVersion.Revision = revision;

    return packageVersion;
}

int WINAPI wWinMain(HINSTANCE, HINSTANCE, LPWSTR, int)
{
    try
    {
        winrt::init_apartment(winrt::apartment_type::single_threaded);

        HRESULT hr{};

        // Hook up dynamic dependencies
        wil::unique_process_heap_ptr<wchar_t> packageDependencyId;
        {
            constexpr PSID user = nullptr;
            const wchar_t* const packageFamilyName = WINDOWSAPPSDK_RUNTIME_PACKAGE_FRAMEWORK_PACKAGEFAMILYNAME_W;
            constexpr PACKAGE_VERSION minVersion = PackageVersion(WINDOWSAPPSDK_RELEASE_MAJOR, WINDOWSAPPSDK_RELEASE_MINOR);
            constexpr PackageDependencyProcessorArchitectures packageDependencyProcessorArchitectures = PackageDependencyProcessorArchitectures_X64;
            constexpr PackageDependencyLifetimeKind lifetimeKind = PackageDependencyLifetimeKind_Process;
            const wchar_t* const lifetimeArtifact = nullptr;
            constexpr CreatePackageDependencyOptions options = CreatePackageDependencyOptions_None;

            hr = ::TryCreatePackageDependency(
                user, packageFamilyName, minVersion, packageDependencyProcessorArchitectures, lifetimeKind, lifetimeArtifact, options, wil::out_param(packageDependencyId));
            THROW_IF_FAILED(hr);
        }

        wil::unique_package_dependency_context packageDependencyContext;
        wil::unique_process_heap_ptr<wchar_t> packageFullName;
        {
            const std::int32_t rank{0};
            const AddPackageDependencyOptions options{AddPackageDependencyOptions_None};

            hr = ::AddPackageDependency(packageDependencyId.get(), rank, options, wil::out_param(packageDependencyContext), wil::out_param(packageFullName));
            THROW_IF_FAILED(hr);
        }

        Application::Start([](const ApplicationInitializationCallbackParams& parameters) { winrt::make<App>(); });
    }
    catch (const wil::ResultException&)
    {
        return -1;
    }
    catch (const winrt::hresult_error&)
    {
        return -1;
    }
    catch (const std::exception&)
    {
        return -1;
    }

    return 0;
}
