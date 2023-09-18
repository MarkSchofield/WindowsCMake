#include "Class.h"
#include "Class.g.cpp"
#include "pch.h"

namespace winrt::RuntimeComponent::implementation
{
    int32_t Class::MyProperty()
    {
        return m_myProperty;
    }

    void Class::MyProperty(int32_t value)
    {
        m_myProperty = value;
    }
} // namespace winrt::RuntimeComponent::implementation
