# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    InitMethod

A method to initialize buffers in geostatistical solvers.
"""
abstract type InitMethod end

"""
    initbuff(sdata, sdomain, method; [varstypes])

Initialize buffers for all variables and types `varstypes`
with given `method` based on the location of elements in
`sdata` and `sdomain`.
"""
function initbuff(sdata, sdomain, method::InitMethod; varstypes=varstypesof(sdata))
  buff, mask = alloc(varstypes, nelements(sdomain))

  if !isnothing(sdata)
    preproc = preprocess(sdata, sdomain, method)
    for var in keys(varstypes) ∩ varsof(sdata)
      initbuff!(buff[var], mask[var], valuesof(sdata, var), method, preproc)
    end
  end

  buff, mask
end

function alloc(varstypes, n)
  buff = Dict(var => Vector{V}(undef, n) for (var, V) in varstypes)
  mask = Dict(var => falses(n) for (var, V) in varstypes)
  buff, mask
end

varstypesof(sdata) = Dict(var => mactypeof(sdata, var) for var in varsof(sdata))

varsof(sdata) = setdiff(propertynames(sdata), [:geometry])

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
