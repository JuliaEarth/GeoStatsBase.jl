# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    VariableJoiner()

Join spatial data with shared domain to produce
spatial data with all variables included.
"""
struct VariableJoiner <: AbstractJoiner
end

function Base.join(sdata₁::AbstractData, sdata₂::AbstractData, joiner::VariableJoiner)
  @assert npoints(sdata₁) == npoints(sdata₂) "cannot join different number of points"

  # retrieve variable names and types
  vars₁ = variables(sdata₁)
  vars₂ = variables(sdata₂)

  # variable names as vectors
  vnames₁ = collect(keys(vars₁))
  vnames₂ = collect(keys(vars₂))

  # find common variable names
  allvars = vnames₁ ∪ vnames₂
  comvars = vnames₁ ∩ vnames₂

  # find common names with same type
  stvars, dtvars = [], []
  for v in comvars
    if nonmissingtype(vars₁[v]) == nonmissingtype(vars₂[v])
      push!(stvars, v)
    else
      push!(dtvars, v)
    end
  end

  # warn if same name has two different types
  isempty(dtvars) || @warn "variables $dtvars have multiple types"

  # create single dictionary with all variables
  pairs = []
  for v in vnames₁
    if v ∈ comvars
      push!(pairs, Symbol(v, 1) => sdata₁[v])
    else
      push!(pairs, v => sdata₁[v])
    end
  end
  for v in vnames₂
    if v ∈ comvars
      push!(pairs, Symbol(v, 2) => sdata₂[v])
    else
      push!(pairs, v => sdata₂[v])
    end
  end

  dict = OrderedDict([(k, v) for (k, v) in pairs])

  georef(dict, domain(sdata₁))
end
