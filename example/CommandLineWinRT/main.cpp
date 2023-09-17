//---------------------------------------------------------------------------------------------------------------------
//
//---------------------------------------------------------------------------------------------------------------------
#include <fcntl.h>
#include <io.h>
#include <iomanip>
#include <iostream>
#include <string_view>
#include <winrt/RuntimeComponent.h>
#include <winrt/Windows.Foundation.Collections.h>
#include <winrt/Windows.Web.Syndication.h>

using namespace winrt;
using namespace Windows::Foundation;
using namespace Windows::Web::Syndication;

int main()
{
    try
    {
        winrt::init_apartment();

        _setmode(_fileno(stdout), _O_U16TEXT);

        RuntimeComponent::Class c;
        c.MyProperty(42);
        std::wcout << "c.MyProperty() = " << c.MyProperty() << std::endl;

        Uri rssFeedUri{L"https://www.engadget.com/rss.xml"};
        SyndicationClient syndicationClient;
        SyndicationFeed syndicationFeed = syndicationClient.RetrieveFeedAsync(rssFeedUri).get();
        for (SyndicationItem syndicationItem : syndicationFeed.Items())
        {
            winrt::hstring titleAsHstring = syndicationItem.Title().Text();
            std::wcout << std::wstring_view{titleAsHstring} << std::endl;
        }
    }
    catch (const winrt::hresult_error& ex)
    {
        std::wcerr << L"Exception: " << std::wstring_view{ex.message()} << L"\n";
    }
    catch (const std::exception& ex)
    {
        std::cerr << "Exception: " << ex.what() << "\n";
    }
}
