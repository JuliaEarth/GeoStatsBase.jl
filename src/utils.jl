# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

"""
    readgeotable(args; coordnames=[:x,:y,:z], kwargs)

Read data from disk using `CSV.read`, optionally specifying
the columns `coordnames` with spatial coordinates.

The arguments `args` and keyword arguments `kwargs` are
forwarded to the `CSV.read` function, please check their
documentation for more details.

This function returns a [`GeoDataFrame`](@ref) object.
"""
readgeotable(args...; coordnames=[:x,:y,:z], kwargs...) =
  GeoDataFrame(read(args...; kwargs...), coordnames)

"""
      split(object, fraction, [direction])

Split spatial `object` into two parts where the first
part has a `fraction` of the total volume. The split
is performed along a `direction`. The default direction
is aligned with the first spatial dimension of the object.
"""
function Base.split(object::AbstractSpatialObject{T,N},
                    fraction::Real, direction=nothing) where {N,T}
  normal = direction ≠ nothing ? direction :
                                 ntuple(i -> i == 1 ? one(T) : zero(T), N)
  partitioner = BisectFractionPartitioner(normal, fraction)
  partition(object, partitioner)
end
