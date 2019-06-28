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

"""
    DataCollection(data₁, data₂, ...)
    DataCollection([data₁, data₂, ...])

A collection of data `data₁`, `data₂`, ...
"""
struct DataCollection{T,N} <: AbstractSpatialData{T,N}
  data::Vector{AbstractSpatialData{T,N}}
  domain::DomainCollection{T,N}
  offsets::Vector{Int}
end

function DataCollection(data::AbstractVector{AbstractSpatialData{T,N}}) where {N,T}
  cdomain = DomainCollection(domain.(data))
  offsets = cumsum([npoints(d) for d in data])
  DataCollection{T,N}(data, cdomain, offsets)
end

DataCollection(data::Vararg{AbstractSpatialData{T,N}}) where {N,T} =
  DataCollection([d for d in data])

variables(collection::DataCollection) = merge([variables(d) for d in collection.data]...)

function value(collection::DataCollection, ind::Int, var::Symbol)
  k = findfirst(ind .≤ collection.offsets)
  d = collection.data[k]
  if var ∈ keys(variables(d))
    i = k > 1 ? (@inbounds return ind - collection.offsets[k-1]) : ind
    value(collection.data[k], i, var)
  else
    missing
  end
end

# ------------
# IO methods
# ------------
function Base.show(io::IO, collection::DataCollection{T,N}) where {N,T}
  ndata = length(collection.data)
  print(io, "$ndata DataCollection{$T,$N}")
end

function Base.show(io::IO, ::MIME"text/plain", collection::DataCollection{T,N}) where {N,T}
  println(io, collection)
  for d in collection.data
    println(io, "└─", d)
  end
end
