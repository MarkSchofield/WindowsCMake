//---------------------------------------------------------------------------------------------------------------------
//
//---------------------------------------------------------------------------------------------------------------------
#pragma once

#if !defined(WIN32_LEAN_AND_MEAN)
#    define WIN32_LEAN_AND_MEAN
#endif

#include <SDKDDKVer.h>

#include <malloc.h>
#include <memory.h>
#include <stdlib.h>
#include <tchar.h>
#include <windows.h>

#include <winrt/base.h>

#include <appmodel.h>
#include <wil/resource.h>
#include <wil/result_macros.h>

#undef GetCurrentTime

#include <winrt/Microsoft.UI.Xaml.Controls.Primitives.h>
#include <winrt/Microsoft.UI.Xaml.Controls.h>
#include <winrt/Microsoft.UI.Xaml.Markup.h>
#include <winrt/Microsoft.UI.Xaml.XamlTypeInfo.h>
#include <winrt/Windows.Foundation.Collections.h>
#include <winrt/Windows.UI.Xaml.Interop.h>
