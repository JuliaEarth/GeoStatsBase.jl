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
function initbuff(sdata::Data, sdomain::Domain, method::InitMethod; vars=defaultvars(sdata))
  @assert vars ⊆ propertynames(sdata) "variables must be present in data"

  mactypeof(var) = nonmissingtype(eltype(valuesof(var)))

  function valuesof(var)
    table = values(sdata)
    cols = Tables.columns(table)
    Tables.getcolumn(cols, var)
  end

  preproc = preprocess(sdata, sdomain, vars, method)

  buffs = map(vars) do var
    V = mactypeof(var)
    n = nelements(sdomain)

    buff = Vector{V}(undef, n)
    vals = valuesof(var)
    initbuff!(buff, vals, method, preproc)

    var => buff
  end

  Dict(buffs)
end

defaultvars(sdata) = setdiff(propertynames(sdata), [:geometry])

# ----------------
# IMPLEMENTATIONS
# ----------------

include("initbuff/nearest.jl")
include("initbuff/explicit.jl")
