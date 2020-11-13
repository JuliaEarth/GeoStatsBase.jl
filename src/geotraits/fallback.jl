# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

nelms(obj) = nelms(domain(obj))

ncoords(obj) = ncoords(domain(obj))

coordtype(obj) = coordtype(domain(obj))

coordinates!(buff, obj, ind) =
  coordinates!(buff, domain(obj), ind)

"""
    coordinates!(buff, object, inds)

Non-allocating version of [`coordinates`](@ref)
"""
function coordinates!(buff, obj, inds::AbstractVector{Int})
  for j in 1:length(inds)
    coordinates!(view(buff,:,j), obj, inds[j])
  end
end

"""
    coordinates(object, ind)

Return the coordinates of the `ind` in the `object`.
"""
function coordinates(obj, ind::Int)
  N = ncoords(obj)
  T = coordtype(obj)
  x = MVector{N,T}(undef)
  coordinates!(x, obj, ind)
  x
end

"""
    coordinates(object, inds)

Return the coordinates of `inds` in the `object`.
"""
function coordinates(obj, inds::AbstractVector{Int})
  N = ncoords(obj)
  T = coordtype(obj)
  X = Matrix{T}(undef, N, length(inds))
  coordinates!(X, obj, inds)
  X
end

"""
    coordinates(object)

Return the coordinates of all indices in `object`.
"""
coordinates(obj) = coordinates(obj, 1:nelms(obj))