# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    SourcePath(domain, sources)

A path over a spatial `domain` that starts at given source
locations `sources` and progresses outwards.
"""
struct SourcePath{D<:AbstractDomain} <: AbstractPath{D}
  domain::D
  sources::Vector{Int}

  # state fields
  path::Vector{Int}

  function SourcePath{D}(domain, sources) where {D<:AbstractDomain}
    @assert all(1 .≤ sources .≤ npoints(domain)) "sources must be valid locations"
    @assert length(unique(sources)) == length(sources) "non-unique sources"
    @assert length(sources) ≤ npoints(domain) "more sources than points in domain"

    # coordinate matrix for source points
    S = coordinates(domain, sources)

    # fit search tree
    kdtree = KDTree(S)

    # other locations that are not sources
    others = setdiff(1:npoints(domain), sources)

    # process points in chunks
    chunksize = 10^3
    chunks = Iterators.partition(others, chunksize)

    # pre-allocate memory for coordinates
    X = Matrix{coordtype(domain)}(undef, ndims(domain), chunksize)

    # compute distances to sources
    dists = []
    for chunk in chunks
      coordinates!(X, domain, chunk)
      _, ds = knn(kdtree, view(X,:,1:length(chunk)), length(sources), true)
      append!(dists, ds)
    end

    path = vcat(sources, view(others, sortperm(dists)))

    new(domain, sources, path)
  end
end

SourcePath(domain, sources) = SourcePath{typeof(domain)}(domain, sources)

Base.iterate(p::SourcePath, state=1) = state > npoints(p.domain) ? nothing : (p.path[state], state + 1)

# ------------
# IO methods
# ------------
function Base.show(io::IO, path::SourcePath)
  print(io, "SourcePath")
end

function Base.show(io::IO, ::MIME"text/plain", path::SourcePath)
  println(io, path)
end
