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
  @assert domain(sdata₁) == domain(sdata₂) "data must reside on same domain"

  # retrieve variable names and types
  vars₁ = variables(sdata₁)
  vars₂ = variables(sdata₂)

  # find common variable names
  allvars = keys(vars₁) ∪ keys(vars₂)
  comvars = keys(vars₁) ∩ keys(vars₂)

  # find common names with same type
  stvars = Set{Symbol}()
  dtvars = Set{Symbol}()
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
  for v in allvars
    if v ∈ comvars
      # append numbers to variable names
      push!(pairs, Symbol(v, 1) => sdata₁[v])
      push!(pairs, Symbol(v, 2) => sdata₂[v])
    else
      if v ∈ keys(vars₁)
        push!(pairs, v => sdata₁[v])
      else
        push!(pairs, v => sdata₂[v])
      end
    end
  end

  georef(Dict(pairs), domain(sdata₁))
end
