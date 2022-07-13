# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    Distributional

A conditional distribution as a function of location.
"""
abstract type Distributional end

"""
    distributional(u)

Return the conditional distribution at location `u`.
"""
(::Distributional)(u) = throw(ErrorException("not implemented"))