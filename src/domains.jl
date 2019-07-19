# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

"""
    AbstractDomain{T,N}

Spatial domain in a `N`-dimensional space with coordinates of type `T`.
"""
abstract type AbstractDomain{T,N} <: AbstractSpatialObject{T,N} end

function bounds(domain::AbstractDomain{T,N}) where {N,T}
  lowerleft  = MVector(ntuple(i->typemax(T), N))
  upperright = MVector(ntuple(i->typemin(T), N))

  x = MVector{N,T}(undef)
  for l in 1:npoints(domain)
    coordinates!(x, domain, l)
    for d in 1:N
      x[d] < lowerleft[d]  && (lowerleft[d]  = x[d])
      x[d] > upperright[d] && (upperright[d] = x[d])
    end
  end

  ntuple(i->(lowerleft[i],upperright[i]), N)
end

"""
    view(domain, locations)

Return a view of `domain` with all points in `locations`.
"""
Base.view(domain::AbstractDomain,
          locations::AbstractVector{Int}) = DomainView(domain, locations)

# ------------
# IO methods
# ------------
function Base.show(io::IO, domain::AbstractDomain{T,N}) where {N,T}
  npts = npoints(domain)
  print(io, "$npts SpatialDomain{$T,$N}")
end

#------------------
# IMPLEMENTATIONS
#------------------
include("domains/curve.jl")
include("domains/point_set.jl")
include("domains/regular_grid.jl")
include("domains/structured_grid.jl")
