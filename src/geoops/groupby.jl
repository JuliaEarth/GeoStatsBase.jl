# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    groupby(data, var)

Partition spatial `data` into groups of constant value
for spatial variable `var`.

### Notes

Missing values are grouped into a separate group.
"""
function groupby(data::Data, var::Symbol)
  vars = Tables.schema(values(data)).names
  @assert var ∈ vars "invalid variable name"

  # data for variable
  vdata = data[var]

  # partition function with missings
  function f(i, j)
    vi, vj = vdata[i], vdata[j]
    mi, mj = ismissing(vi), ismissing(vj)
    (mi && mj) || ((!mi && !mj) && (vi == vj))
  end

  # partition function without missings
  g(i, j) = vdata[i] == vdata[j]

  # select the appropriate predicate function
  pred = Missing <: eltype(vdata) ? f : g

  # perform partition
  p = partition(data, PredicatePartition(pred))

  # retrieve value from each subset
  vals = [vdata[s[1]] for s in indices(p)]

  # save metadata
  metadata = Dict(:values => vals)

  Partition(data, indices(p), metadata)
end
