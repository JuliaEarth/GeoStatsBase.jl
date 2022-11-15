# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    NearestMapping

A mapping method in which data points are assigned to their nearest
point in the domain.
"""
struct NearestMapping <: MappingMethod end

function Base.map(sdata, sdomain, targetvars, ::NearestMapping)
  @assert targetvars ⊆ name.(variables(sdata)) "target variables must be present in spatial data"

  # dictionary with mappings
  mappings = Dict(var => Dict{Int,Int}() for var in targetvars)

  # nearest neighbor search method
  neighbor = Vector{Int}(undef, 1)
  searcher = KNearestSearch(sdomain, 1)

  𝒟 = domain(sdata)

  for ind in 1:nelements(𝒟)
    # update datum coordinates
    pₒ = centroid(𝒟, ind)

    # find nearest location in the domain
    search!(neighbor, pₒ, searcher)

    # save pair if there is data for variable
    for var in targetvars
      v = getproperty(sdata, var)
      if !ismissing(v[ind])
        push!(mappings[var], neighbor[1] => ind)
      end
    end
  end

  mappings
end
