//---------------------------------------------------------------------------------------------------------------------
//
//---------------------------------------------------------------------------------------------------------------------
#include <Windows.h>
#include <iostream>
#include <sstream>
#include <thread>

bool HasConsole()
{
    HANDLE conOut = ::CreateFileW(L"CONOUT$", GENERIC_WRITE, FILE_SHARE_WRITE, nullptr, OPEN_EXISTING, 0, nullptr);
    if (conOut == INVALID_HANDLE_VALUE)
    {
        return false;
    }

    ::CloseHandle(conOut);
    return true;
}

int main(int /*argc*/, char** /*argv*/)
{
    if (HasConsole())
    {
        std::cout << "This is application has a 'detached' consoleAllocationPolicy.\n"
                  << "\n"
                  << "This means that the application will not automatically allocate a console window when it is run. But since this\n"
                  << "process inherited a console, the application will be able to output text to it, and block the calling process.\n"
                  << "\n"
                  << "Try running this application from Windows Explorer, and it should behave like a Windows Application.\n"
                  << std::flush;

        std::this_thread::sleep_for(std::chrono::seconds(2));
    }
    else
    {
        std::stringstream message;
        message
            << "This is application has a 'detached' consoleAllocationPolicy.\n"
            << "\n"
            << "This means that the application will not automatically allocate a console window when it is run. Since this instance was\n"
            << "launched without a console, the application will not be able to output any text to the console, but can show a MessageBox.\n"
            << "\n"
            << "Try running this application from a command prompt, and it should behave like a Console Application.\n"
            << std::flush;

        ::MessageBoxA(nullptr, message.str().c_str(), "No Console Detected", MB_OK | MB_ICONINFORMATION);
    }

    return 0;
}
