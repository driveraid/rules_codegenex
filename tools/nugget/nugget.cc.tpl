#include <iostream>

// This nugget
// ------------------------------------------------
%{nugget}

// Nuggets in this nugget collection
// ------------------------------------------------
%{nuggets}

// Transitive nuggets
// ------------------------------------------------
%{commented_transitive_nuggets}

// Dependent nuggets
// ------------------------------------------------
%{commented_dependent_nuggets}

// Forward declarations
%{fwddecl_dependent_nuggets}

int %{nugget_fn}()
{
    std::cout << "Begin %{nugget_fn}() Operation %{operation} argument %{argument}" << std::endl;
    auto result = 1 %{sum_dependent_nuggets_fn};
    std::cout << "End %{nugget_fn}()" << std::endl;
    return result;
}
