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

function partition(sdata, partitioner::VariablePartitioner)
  var = partitioner.var

  @assert var ∈ name.(variables(sdata)) "invalid variable name"

  # partition function with missings
  function f(i, j)
    vi, vj = sdata[i,var], sdata[j,var]
    mi, mj = ismissing(vi), ismissing(vj)
    (mi && mj) || ((!mi && !mj) && (vi == vj))
  end

  # partition function without missings
  g(i, j) = sdata[i,var] == sdata[j,var]

  # select the appropriate predicate function
  pred = Missing <: eltype(sdata[var]) ? f : g

  # perform partition
  p = partition(sdata, PredicatePartitioner(pred))

  # retrieve value from each subset
  vals = [sdata[s[1],var] for s in subsets(p)]

  # save metadata
  metadata = Dict(:values => vals)

  SpatialPartition(sdata, subsets(p), metadata)
end
