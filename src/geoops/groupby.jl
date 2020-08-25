# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    groupby(sdata, var)

Partition spatial data `sdata` into groups of constant value
for spatial variable `var`.

### Notes

Missing values are grouped into a separate group.
"""
groupby(sdata::AbstractData, var::Symbol) =
  partition(sdata, VariablePartitioner(var))