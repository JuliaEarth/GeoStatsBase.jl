# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    BoundedSearch(method, maxneighbors=Inf; maxpercategory,
    maxperoctant, ordermetric=Euclidean())

A method for searching at most `maxneighbors` neighbors using `method`. Extra
restrictions available: `maxpercategory` and `maxperoctant`. The priority is
given to the nearest neighbor using `ordermetric`.
"""
struct BoundedSearch{M<:NeighborSearchMethod} <: BoundedNeighborSearchMethod
  method::M
  maxneighbors::Int
  maxpercategory::Dict{Symbol,Int}
  maxperoctant::Int
  ordermetric::Metric

  function BoundedSearch{M}(method::M, maxneighbors=0; maxpercategory=Dict(),
                            maxperoctant=0, ordermetric=Euclidean()) where {M}
    new(method, maxneighbors, maxpercategory, maxperoctant, ordermetric)
  end
end

BoundedSearch(method::M, maxneighbors::Int=0; kwargs...) where {M} =
  BoundedSearch{M}(method, maxneighbors; kwargs...)

object(method::BoundedSearch) = object(method.method)

maxneighbors(method::BoundedSearch) = method.maxneighbors

function search!(neighbors, xₒ::AbstractVector,
                 method::BoundedSearch; mask=nothing)
  # get reference objects and initial neighbors
  meth = method.method
  obj  = object(method)
  N    = ncoords(obj)
  inds = search(xₒ, meth, mask=mask)

  # get distances and give priority to closest neighbors according to ordermetric
  ometric = method.ordermetric
  dists   = colwise(ometric, xₒ, coordinates(obj,inds))
  sortids = sortperm(dists)
  inds    = inds[sortids]

  # read constraints
  maxk   = method.maxneighbors
  maxoct = method.maxperoctant
  maxcat = method.maxpercategory
  usek   = maxk   > 0
  useoct = maxoct > 0
  usecat = length(maxcat) > 0

  # initialize octant restriction
  if useoct
    methn = meth isa NeighborhoodSearch ? meth.neigh : nothing
    ellp  = methn isa EllipsoidNeighborhood
    P, _  = ellp ? rotmat(methn.semiaxes, methn.angles, methn.convention) : (0,0)
    octs  = zeros(Int, 2^N)
  end

  # initialize category restriction
  if usecat
    table   = values(obj)
    catgs   = Dict(k => unique(view(table, inds, k)) for k in keys(maxcat))
    ctcatgs = Dict(k => Dict(zip(v, zeros(Int,length(v)))) for (k, v) in catgs)
  end

  nneigh = 0

  @inbounds for ind in inds
    # get octant of current neighbor if necesary
    if useoct
      centered = coordinates(obj,ind) .- xₒ
      P isa AbstractMatrix && (centered = P' * centered)
      oct = getoct(centered)
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
    nneigh += 1
    if usek
      neighbors[nneigh] = ind
    else
      push!(neighbors, ind)
    end
    useoct && (octs[oct] += 1)
    if usecat
      for col in keys(maxcat)
        ctcatgs[col][cat[col]] += 1
      end
    end

    # if maxneigh reached, stop
    usek && nneigh >= maxk && break
  end

  nneigh
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
