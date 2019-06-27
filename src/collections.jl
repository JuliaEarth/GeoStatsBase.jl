# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

"""
    DomainCollection(domain₁, domain₂, ...)
    DomainCollection([domain₁, domain₂, ...])

A collection of domains `domain₁`, `domain₂`, ...
"""
struct DomainCollection{T,N} <: AbstractDomain{T,N}
  domains::Vector{AbstractDomain{T,N}}
  offsets::Vector{Int}
end

DomainCollection(domains::AbstractVector{AbstractDomain{T,N}}) where {N,T} =
  DomainCollection{T,N}(domains, cumsum([npoints(d) for d in domains]))

DomainCollection(domains::Vararg{AbstractDomain{T,N}}) where {N,T} =
  DomainCollection([d for d in domains])

npoints(collection::DomainCollection) = collection.offsets[end]

function coordinates!(buff::AbstractVector{T},
                      collection::DomainCollection{T,N},
                      location::Int) where {N,T}
  k = findfirst(location .≤ collection.offsets)
  l = k > 1 ? (@inbounds return location - collection.offsets[k-1]) : location
  coordinates!(buff, collection.domains[k], l)
end

# ------------
# IO methods
# ------------
function Base.show(io::IO, collection::DomainCollection{T,N}) where {N,T}
  ndomains = length(collection.domains)
  print(io, "$ndomains DomainCollection{$T,$N}")
end

function Base.show(io::IO, ::MIME"text/plain", collection::DomainCollection{T,N}) where {N,T}
  println(io, collection)
  for d in collection.domains
    println(io, "└─", d)
  end
end
