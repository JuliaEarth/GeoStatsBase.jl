# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

"""
    FunctionPartitioner(func)

A method for partitioning spatial objects with a given function `func`.
"""
struct FunctionPartitioner <: AbstractFunctionPartitioner
  func::Function
end

(p::FunctionPartitioner)(i, j) = p.func(i, j)
