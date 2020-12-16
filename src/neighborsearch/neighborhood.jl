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
  maxneighs::Int
  maxperoct::Int
  maxperkey::Tuple{Symbol,Int}
  ordermetric

  # state fields
  tree::T
  restrictions::Bool
end

function NeighborhoodSearch(object::O, neigh::N; maxneighs=0, maxperoct=0,
  maxperkey=(:_,0), ordermetric=Euclidean()) where {O,N}
  tree = if neigh isa BallNeighborhood
    if metric(neigh) isa MinkowskiMetric
      KDTree(coordinates(object), metric(neigh))
    else
      BallTree(coordinates(object), metric(neigh))
    end
  else
    nothing
  end

  usek       = maxneighs    > 0
  useoct     = maxperoct    > 0
  usekey     = maxperkey[2] > 0
  filterinds = usek || useoct || usekey

  NeighborhoodSearch{O,N,typeof(tree)}(object, neigh, maxneighs, maxperoct,
  maxperkey, ordermetric, tree, filterinds)
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
                mask=nothing) where {O,N<:BallNeighborhood,T}
  inds = inrange(method.tree, xₒ, radius(method.neigh))
  if mask ≠ nothing
    neighbors = Vector{Int}()
    @inbounds for ind in inds
      if mask[ind]
        push!(neighbors, ind)
      end
    end
    method.restrictions && (neighbors = filterneighs(neighbors, method, xₒ))
    neighbors
  else
    method.restrictions && (inds = filterneighs(inds, method, xₒ))
    inds
  end
end

function filterneighs(inds::AbstractVector, method::NeighborhoodSearch{O,N,T},
  xₒ::AbstractVector) where {O,N<:BallNeighborhood,T}

  object   = method.object
  neigh    = method.neigh
  rotmat   = neigh.metric isa Mahalanobis ? neigh.metric.qmat : I
  ometric  = method.ordermetric
  maxk     = method.maxneighs
  maxoct   = method.maxperoct
  maxkey   = method.maxperkey
  usek     = 0 < maxk < length(inds)
  useoct   = maxoct > 0
  usekey   = maxkey[2] > 0

  # get distances and give priority to closest neighbors according to ordermetric
  dists   = colwise(ometric, xₒ, coordinates(object,inds))
  sortids = sortperm(dists)
  inds    = inds[sortids]

  # key and octant constraints
  keys   = usekey ? unique(view(values(object), inds, maxkey[1])) : nothing
  dkeys  = usekey ? Dict(zip(keys, 1:length(keys)))               : nothing
  ctkeys = usekey ? zeros(Int, length(keys))                      : nothing
  octs   = useoct ? zeros(Int, 8)                                 : nothing

  neighbors = Vector{Int}()
  ctneighs  = 0

  @inbounds for ind in inds
    key = usekey ? values(object)[ind,maxkey[1]]                    : nothing
    oct = useoct ? getoct(rotmat * (coordinates(object,ind) .- xₒ)) : nothing

    usekey && ctkeys[dkeys[key]] >= maxkey[2] && continue
    useoct && octs[oct] >= maxoct             && continue

    # if valid, add as a neighbor
    push!(neighbors, ind)
    ctneighs += 1
    usekey && (ctkeys[dkeys[key]] += 1)
    useoct && (octs[oct] += 1)

    # if maxneigh reached, stop
    usek && ctneighs >= maxk && break
  end

  neighbors
end


# get octant code of transformed coordinates
function getoct(coords::AbstractVector)
  N = size(coords,1)
  i = (coords .< 0) .+ 1

  octid = N == 2 ? reshape(1:4,(2,2)) : reshape(1:8,(2,2,2))
  oct   = N == 2 ? octid[i[1],i[2]]   : octid[i[1],i[2],i[3]]
  oct
end
