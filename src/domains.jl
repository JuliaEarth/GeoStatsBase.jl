# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    AbstractDomain

An abstract type to aid with custom spatial domain types. Users
can subtype their domains from this type, and implement the methods
in `geotraits/domain.jl`.
"""
abstract type AbstractDomain end

"""
    view(domain, inds)

Return a view of `domain` at given indices `inds`.
"""
Base.view(domain::AbstractDomain, inds::AbstractVector{Int}) =
  DomainView(domain, inds)

#------------------
# IMPLEMENTATIONS
#------------------
"""
    SpatialDomain{T,N}

Spatial domain in a `N`-dimensional space with coordinates of type `T`.
"""
abstract type SpatialDomain{T,N} <: AbstractDomain end

ncoords(::SpatialDomain{T,N}) where {T,N} = N
coordtype(::SpatialDomain{T,N}) where {T,N} = T

include("domains/point_set.jl")
include("domains/regular_grid.jl")
include("domains/structured_grid.jl")

"""
    DomainView(domain, inds)

Return a view of `domain` at `inds`.
"""
struct DomainView{𝒟,I} <: AbstractDomain
  domain::𝒟
  inds::I
end

nelms(dv::DomainView) = length(dv.inds)
ncoords(dv::DomainView) = ncoords(dv.domain)
coordtype(dv::DomainView) = coordtype(dv.domain)
coordinates!(buff::AbstractVector, dv::DomainView, ind::Int) =
  coordinates!(buff, dv.domain, dv.inds[ind])

==(dv₁::DomainView, dv₂::DomainView) =
  dv₁.domain == dv₂.domain && dv₁.inds == dv₂.inds

Base.collect(dv::DomainView) = PointSet(coordinates(dv))

function Base.show(io::IO, dv::DomainView)
  N = ncoords(dv)
  T = coordtype(dv)
  npts = nelms(dv)
  print(io, "$npts DomainView{$T,$N}")
end

function Base.show(io::IO, ::MIME"text/plain", dv::DomainView)
  println(io, dv)
  Base.print_array(io, coordinates(dv))
end
