# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

"""
    AbstractDomain{T,N}

Spatial domain in a `N`-dimensional space with coordinates of type `T`.
"""
abstract type AbstractDomain{T<:Real,N} <: AbstractSpatialObject{T,N} end

function bounds(domain::AbstractDomain{T,N}) where {N,T<:Real}
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

function nearestlocation(domain::AbstractDomain{T,N},
                         coords::AbstractVector{T}) where {N,T<:Real}
  lmin, dmin = 0, Inf
  c = MVector{N,T}(undef)
  for l in 1:npoints(domain)
    coordinates!(c, domain, l)
    d = norm(coords - c)
    d < dmin && ((lmin, dmin) = (l, d))
  end

  lmin
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
function Base.show(io::IO, domain::AbstractDomain{T,N}) where {N,T<:Real}
  npts = npoints(domain)
  print(io, "$npts SpatialDomain{$T,$N}")
end
