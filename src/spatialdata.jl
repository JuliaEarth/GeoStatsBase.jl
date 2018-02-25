# ------------------------------------------------------------------
# Copyright (c) 2017, Júlio Hoffimann Mendes <juliohm@stanford.edu>
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

"""
    AbstractSpatialData

A container with spatial data.
"""
abstract type AbstractSpatialData end

"""
    coordinates(spatialdata)

Return the name of the coordinates in `spatialdata` and their types.
"""
coordinates(::AbstractSpatialData) = error("not implemented")

"""
    variables(spatialdata)

Return the variable names in `spatialdata` and their types.
"""
variables(::AbstractSpatialData) = error("not implemented")

"""
    npoints(spatialdata)

Return the number of points in `spatialdata`.
"""
npoints(::AbstractSpatialData) = error("not implemented")

"""
    coordinates(spatialdata, idx)

Return the coordinates of the `idx`-th point in `spatialdata`.
"""
coordinates(::AbstractSpatialData, ::Int) = error("not implemented")

"""
    value(spatialdata, idx, var)

Return the value of `var` for the `idx`-th point in `spatialdata`.
"""
value(::AbstractSpatialData, ::Int, ::Symbol) = error("not implemented")

"""
    isvalid(spatialdata, idx, var)

Return `true` if the `idx`-th point in `spatialdata` has a valid value for `var`.
"""
Base.isvalid(::AbstractSpatialData, ::Int, ::Symbol) = error("not implemented")

"""
    valid(spatialdata, var)

Return all points in `spatialdata` with a valid value for `var`. The output
is a tuple with the matrix of coordinates as the first item and the vector
of values as the second item.
"""
function valid(spatialdata::AbstractSpatialData, var::Symbol)
  # determine coordinate and value type
  T = coordtype(spatialdata)
  V = valuetype(spatialdata, var)

  # provide size hint for output
  xs = Vector{Vector{T}}(); zs = Vector{V}()
  sizehint!(xs, npoints(spatialdata))
  sizehint!(zs, npoints(spatialdata))

  for location in 1:npoints(spatialdata)
    if isvalid(spatialdata, location, var)
      push!(xs, coordinates(spatialdata, location))
      push!(zs, value(spatialdata, location, var))
    end
  end

  # return matrix and vector
  hcat(xs...), zs
end

"""
    coordtype(spatialdata)

Return the promoted type of all individual coordinates of `spatialdata`.
"""
function coordtype(spatialdata::AbstractSpatialData)
  datacoords = coordinates(spatialdata)
  promote_type([T for (var,T) in datacoords]...)
end

"""
    valuetype(spatialdata, var)

Return the value type of `var` in `spatialdata`.
"""
valuetype(spatialdata::AbstractSpatialData, var::Symbol) = variables(spatialdata)[var]

"""
    view(spatialdata, inds)

Return a view of `spatialdata` with all points in `inds` locations.
"""
Base.view(spatialdata::AbstractSpatialData, inds::AbstractVector{Int}) = error("not implemented")
