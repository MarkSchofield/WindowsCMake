//---------------------------------------------------------------------------------------------------------------------
//
//---------------------------------------------------------------------------------------------------------------------
#include <exception>
#include <iostream>

int x[100];

int main(int /*argc*/, char** /*argv*/)
{
    try
    {
        std::cout << "Hello, World!";

        // This is an intentional out-of-bounds access to demonstrate AddressSanitizer, suppress the warning to avoid compilation errors.
#pragma warning(push)
#pragma warning(disable : 4068) // Disable MSVC warning for unknown pragma
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warray-bounds"
        x[100] = 5;
#pragma clang diagnostic pop
#pragma warning(pop)
    }
    catch (const std::exception& ex)
    {
        std::cout << "Exception: " << ex.what();
    }
}
