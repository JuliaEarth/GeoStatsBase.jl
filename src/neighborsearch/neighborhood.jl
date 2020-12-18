# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    NeighborhoodSearch(object, neighborhood)

A method for searching neighbors in spatial `object` inside `neighborhood`.
"""
struct NeighborhoodSearch{O,N,T} <: NeighborSearchMethod
  # input fields
  object::O
  neigh::N
  maxneighbors::Int
  maxperoctant::Int
  maxpercategory::Dict{Symbol,Int}
  ordermetric::Metric

  # state fields
  tree::T
end

function NeighborhoodSearch(object::O, neigh::N; maxneighbors=0, maxperoctant=0,
  maxpercategory=Dict(), ordermetric=Euclidean()) where {O,N}
  tree = if neigh isa AbstractBallNeighborhood
    if metric(neigh) isa MinkowskiMetric
      KDTree(coordinates(object), metric(neigh))
    else
      BallTree(coordinates(object), metric(neigh))
    end
  else
    nothing
  end

  NeighborhoodSearch{O,N,typeof(tree)}(object, neigh, maxneighbors,
  maxperoctant, maxpercategory, ordermetric, tree)
end

# search method for any neighborhood
function search(xₒ::AbstractVector, method::NeighborhoodSearch; mask=nothing)
  object = method.object
  neigh  = method.neigh
  N = ncoords(object)
  T = coordtype(object)
  n = nelms(object)

  inds = mask ≠ nothing ? view(1:n, mask) : 1:n

  x = MVector{N,T}(undef)

  neighbors = Vector{Int}()
  @inbounds for ind in inds
    coordinates!(x, object, ind)
    if isneighbor(neigh, xₒ, x)
      push!(neighbors, ind)
    end
  end

  neighbors
end

# search method for ball neighborhood
function search(xₒ::AbstractVector, method::NeighborhoodSearch{O,N,T};
                mask=nothing) where {O,N<:AbstractBallNeighborhood,T}
  inds = inrange(method.tree, xₒ, radius(method.neigh))

  # check if there is some restriction requested in the constructor
  usek       = method.maxneighbors > 0
  useoct     = method.maxperoctant > 0
  usecat     = length(method.maxpercategory) > 0
  restrict   = usek || useoct || usecat

  if mask ≠ nothing
    neighbors = Vector{Int}()
    @inbounds for ind in inds
      if mask[ind]
        push!(neighbors, ind)
      end
    end
    restrict && (neighbors = filterneighs(neighbors, method, xₒ))
    neighbors
  else
    restrict && (inds = filterneighs(inds, method, xₒ))
    inds
  end
end

function filterneighs(inds::AbstractVector, method::NeighborhoodSearch{O,N,T},
  xₒ::AbstractVector) where {O,N<:AbstractBallNeighborhood,T}

  # get reference objects
  obj = method.object
  ngh = method.neigh

  # get distances and give priority to closest neighbors according to ordermetric
  ometric = method.ordermetric
  dists   = colwise(ometric, xₒ, coordinates(obj,inds))
  sortids = sortperm(dists)
  inds    = inds[sortids]

  # read constraints
  maxk   = method.maxneighbors
  maxoct = method.maxperoctant
  maxcat = method.maxpercategory
  usek   = 0 < maxk < length(inds)
  useoct = maxoct > 0
  usecat = length(maxcat) > 0

  # initialize octant restriction
  if useoct
    ellp = ngh isa EllipsoidNeighborhood
    P, _ = ellp ? rotmat(ngh.semiaxes, ngh.angles, ngh.convention) : (I, nothing)
    octs = zeros(Int, 8)
  end

  # initialize category restriction
  if usecat
    table   = values(obj)
    catgs   = Dict(k => unique(view(table, inds, k)) for k in keys(maxcat))
    ctcatgs = Dict(k => Dict(zip(v, zeros(Int,length(v)))) for (k, v) in catgs)
  end

  neighbors = Vector{Int}()
  ctneighs  = 0

  @inbounds for ind in inds
    # get octant of current neighbor if necesary
    if useoct
      oct = getoct(P' * (coordinates(obj,ind) .- xₒ))
      octs[oct] >= maxoct && continue
    end

    # get category of current neighbor if necesary
    if usecat
      cat, pass = Dict(), false
      for col in keys(maxcat)
        cat[col] = table[ind,col]
        ctcatgs[col][cat[col]] >= maxcat[col] && (pass = true)
      end
      pass && continue
    end

    # if ind was not ignored, add it as a neighbor and increment +1 to the counters
    push!(neighbors, ind)
    ctneighs += 1
    useoct && (octs[oct] += 1)
    if usecat
      for col in keys(maxcat)
        ctcatgs[col][cat[col]] += 1
       end
     end

    # if maxneigh reached, stop
    usek && ctneighs >= maxk && break
  end

  neighbors
end


# get octant code of centered coordinates
function getoct(coords::AbstractVector)
  # get dimensions
  N    = size(coords,1)
  dims = Tuple([2 for x in 1:N])

  # get which coord is negative. assign an id to each octant
  signcoord = (coords .< 0) .+ 1
  octid     = reshape(1:2^N, dims)

  # return octant id to combination of coordinates signs
  octid[signcoord...]
end
