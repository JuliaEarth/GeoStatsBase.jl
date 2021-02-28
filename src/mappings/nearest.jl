# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    NearestMapping

A mapping method in which data points are assigned to their nearest
point in the domain.
"""
struct NearestMapping <: MappingMethod end

function map(sdata, sdomain, targetvars, ::NearestMapping)
  N = embeddim(sdata)
  T = coordtype(sdata)

  @assert targetvars ⊆ name.(variables(sdata)) "target variables must be present in spatial data"

  # dictionary with mappings
  mappings = Dict(var => Dict{Int,Int}() for var in targetvars)

  # pre-allocate memory for coordinates
  coords = MVector{N,T}(undef)

  # nearest neighbor search method
  neighbor = Vector{Int}(undef, 1)
  searcher = KNearestSearch(sdomain, 1)

  for ind in 1:nelements(sdata)
    # update datum coordinates
    coordinates!(coords, sdata, ind)

    # find nearest location in the domain
    search!(neighbor, Point(coords), searcher)

    # save pair if there is data for variable
    for var in targetvars
      if !ismissing(sdata[var][ind])
        push!(mappings[var], neighbor[1] => ind)
      end
    end
  end

  mappings
end
