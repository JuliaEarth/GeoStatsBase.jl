## Copyright (c) 2017, Júlio Hoffimann Mendes <juliohm@stanford.edu>
##
## Permission to use, copy, modify, and/or distribute this software for any
## purpose with or without fee is hereby granted, provided that the above
## copyright notice and this permission notice appear in all copies.
##
## THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
## WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
## MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
## ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
## WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
## ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
## OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

"""
    SimpleMapper

A mapping strategy in which data points are assigned to their nearest
point in the domain.
"""
struct SimpleMapper <: AbstractMapper end

function Base.map(spatialdata::S, domain::D, targetvars::Vector{Symbol},
                  mapper::SimpleMapper) where {S<:AbstractSpatialData,D<:AbstractDomain}
  @assert targetvars ⊆ keys(variables(spatialdata)) "target variables must be present in spatial data"

  # dictionary with mappings
  mappings = Dict(var => Dict{Int,Int}() for var in targetvars)

  for location in 1:npoints(spatialdata)
    # get datum coordinates
    coords = coordinates(spatialdata, location)

    # find nearest location in the domain
    near = nearestlocation(domain, coords)

    # save pair if there is data for variable
    for var in targetvars
      if isvalid(spatialdata, location, var)
        push!(mappings[var], near => location)
      end
    end
  end

  mappings
end
