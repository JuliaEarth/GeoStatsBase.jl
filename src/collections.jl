# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
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

function DomainCollection(domains::AbstractVector)
  T = coordtype(domains[1])
  N = ndims(domains[1])
  offsets = cumsum([npoints(d) for d in domains])
  DomainCollection{T,N}(domains, offsets)
end

DomainCollection(domains::Vararg) where {N,T} =
  DomainCollection([d for d in domains])

npoints(collection::DomainCollection) = collection.offsets[end]

function coordinates!(buff::AbstractVector{T},
                      collection::DomainCollection{T,N},
                      location::Int) where {N,T}
  k = findfirst(off -> location ≤ off, collection.offsets)
  l = k > 1 ? location - collection.offsets[k-1] : location
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
struct DataCollection{T,N} <: AbstractData{T,N}
  data::Vector{AbstractData{T,N}}
  domain::DomainCollection{T,N}
  offsets::Vector{Int}
  variables::Dict{Symbol,Type}
  varnames::Vector{Symbol}
end

function DataCollection(data::AbstractVector)
  cdomain = DomainCollection(domain.(data))
  T = coordtype(cdomain)
  N = ndims(cdomain)
  offsets = cumsum([npoints(d) for d in data])
  vars    = reduce(merge, [variables(d) for d in data])
  vnames  = collect(keys(vars))
  DataCollection{T,N}(data, cdomain, offsets, vars, vnames)
end

DataCollection(data::Vararg) =
  DataCollection([d for d in data])

variables(collection::DataCollection) = collection.variables

function Base.getindex(collection::DataCollection, ind::Int, var::Symbol)
  k = findfirst(off -> ind ≤ off, collection.offsets)
  d = collection.data[k]
  if var ∈ collection.varnames
    i = k > 1 ? ind - collection.offsets[k-1] : ind
    getindex(d, i, var)
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
