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

// Include the code for 'Microsoft::Windows::ApplicationModel::DynamicDependency::Bootstrap'
// to add a dynamic dependency on the Store-distributed runtime.
#include <MddBootstrap.h>

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
        auto initializationScope = Microsoft::Windows::ApplicationModel::DynamicDependency::Bootstrap::Initialize();

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
