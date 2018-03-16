#include <iostream>

// Fwd decl; didn't generate headers
int animal();

int main()
{
    int result = animal();
    std::cout << "Animal: " << result << std::endl;
    bool passed = result == 5;
    if (passed)
    {
        return 0;
    }
    return 1;
}