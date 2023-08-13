# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    InitMethod

A method to initialize buffers in geostatistical solvers.
"""
abstract type InitMethod end

"""
    initbuff(sdata, sdomain, method; [vars])

Initialize buffers for all variables `vars` with given `method`
based on the location of elements in `sdata` and `sdomain`.
"""
function initbuff(sdata, sdomain, method::InitMethod; vars=variables(sdata))
  buff, mask = allocbuff(vars, nelements(sdomain))

  if !isnothing(sdata)
    preproc = preprocess(sdata, sdomain, method)
    for var in keys(vars) ∩ varnames(sdata)
      initbuff!(buff[var], mask[var], valuesof(sdata, var), method, preproc)
    end
  end

  buff, mask
end

function allocbuff(vars, n)
  names = keys(vars)
  types = values(vars)
  buff = Dict(var => Vector{V}(undef, n) for (var, V) in zip(names, types))
  mask = Dict(var => falses(n) for var in names)
  buff, mask
end

function variables(sdata)
  names = varnames(sdata)
  types = [mactypeof(sdata, var) for var in names]
  (; zip(names, types)...)
end

varnames(sdata) = setdiff(propertynames(sdata), [:geometry])

mactypeof(sdata, var) = nonmissingtype(eltype(valuesof(sdata, var)))

function valuesof(sdata, var)
  table = values(sdata)
  cols = Tables.columns(table)
  Tables.getcolumn(cols, var)
end

# ----------------
# IMPLEMENTATIONS
# ----------------

include("initbuff/nearest.jl")
include("initbuff/explicit.jl")
