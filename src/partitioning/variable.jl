# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    VariablePartitioner(var)

A method for partitioning spatial data into subsets of
constant value for variable `var`.
"""
struct VariablePartitioner <: AbstractPartitioner
  var::Symbol
end

function partition(sdata::AbstractData,
                   partitioner::VariablePartitioner)
  var = partitioner.var
  f(i, j) = sdata[i,var] == sdata[j,var]
  partition(sdata, FunctionPartitioner(f))
end
