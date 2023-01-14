# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
   Potrace(col)

Trace polygons on 2D image data with Selinger's Potrace algorithm.

## References

- Selinger, P. 2003. [Potrace: A polygon-based tracing algorithm]
  (https://potrace.sourceforge.net/potrace.pdf)
"""
struct Potrace{S<:ColSpec} <: StatelessTableTransform
  colspec::S
end

Potrace(col::Col) = Potrace(colspec([col]))

isrevertible(::Type{<:Potrace}) = true

function apply(transform::Potrace, data)
  tab = values(data)
  dom = domain(data)

  # sanity check
  if !(dom isa Grid)
    throw(ArgumentError("potrace only defined for grid data"))
  end

  # select column name
  cols  = Tables.columns(tab)
  names = Tables.columnnames(cols)
  sname = choose(transform.colspec, names) |> first

  # convert column to image
  col = Tables.getcolumn(cols, sname)
  img = reshape(col, size(dom))

  # all possible colors
  colors = unique(img)

  # aggregate variables within each color
  preproc = map(colors) do color
    mask = isequal.(img, color)
    inds = findall(vec(mask))
    feat = [sname => color]
    for name in setdiff(names, [sname])
      col = Tables.getcolumn(cols, name)
      val = aggregate(view(col, inds))
      push!(feat, name => val)
    end
    (; feat...), mask
  end

  # split preprocessing results
  feats = first.(preproc)
  masks = last.(preproc)

  # collect vertices and topology
  verts = vertices(dom)
  topo  = topology(dom)

  # map pixels to vertices
  ∂ = Boundary{2,0}(topo)

  # map direction to first vertex of edge of
  # interest (i.e. edge touched by direction)
  d = Dict(:→ => 1, :↑ => 2, :← => 3, :↓ => 4)

  # map (→, i) representation to (x, y) point
  points(chain) = [verts[∂(i)[d[→]]] for (→, i) in chain]

  elems = map(masks) do mask
    paths = potrace(mask)
    polys = map(paths) do (outer, inners)
      opoints = points(outer)
      ipoints = [points(inner) for inner in inners]
      PolyArea(opoints, ipoints)
    end
    Multi(polys)
  end

  newtab = feats |> Tables.materializer(tab)
  newdom = elems |> Collection
  newdat = georef(newtab, newdom)

  newdat, nothing
end

function revert(transform::Potrace, data, cache)
  # TODO: implement rasterization
  @assert "not implemented"
end

# aggregate vector of values into a single value
aggregate(x) = aggregate(nonmissingtype(elscitype(x)), x)
aggregate(::Type{<:Continuous}, x) = mean(x)
aggregate(::Type{<:Any}, x) = mode(x)

# trace polygonal geometries on mask
function potrace(mask)
  # pad mask with inactive pixels
  M = falses(size(mask) .+ 2)
  M[begin+1:end-1,begin+1:end-1] .= mask

  # trace paths on padded mask
  paths = potracerecursion!(M)

  # unpad and linearize indices
  linear = LinearIndices(mask)
  fun(■) = linear[■ - CartesianIndex(1,1)]
  map(paths) do path
    outer, inners = path
    o  = [(→, fun(■)) for (□, →, ■) in outer]
    is = [[(→, fun(■)) for (□, →, ■) in inner] for inner in inners]
    o, is
  end
end

function potracerecursion!(M)
  paths = []
  while any(M)
    # trace outer path
    outer = tracepath(M)

    # invert pixels inside path
    O = copy(M)
    insideout!(M, outer)
    I = @. M & !O
    @. M = M & !I

    if any(I)
      # append inner paths
      inners = potracerecursion!(I)
      push!(paths, (outer, first.(inners)))
    else
      # single outer path
      push!(paths, (outer, []))
    end
  end

  paths
end

# trace the top-left polygon on the mask
function tracepath(M)
  # find top-left corner (□ → ■ link)
  i, j = 1, findfirst(==(1), M[1,:])
  while isnothing(j) && i < size(M, 1)
    i += 1
    j = findfirst(==(1), M[i,:])
  end

  # there must be at least one active pixel
  @assert !isnothing(j) "invalid input mask"

  # define □ → ■ link
  □ = CartesianIndex(i, j-1)
  ■ = CartesianIndex(i, j)
  
  # step direction along the path
  step(□, ■) = CartesianIndex(■[2] - □[2], □[1] - ■[1])
  
  # direction after a given turn
  left  = Dict(:→ => :↑, :↑ => :←, :← => :↓, :↓ => :→)
  right = Dict(:→ => :↓, :↓ => :←, :← => :↑, :↑ => :→)
    
  # find the next edge along the path
  function move((□, →, ■))
    □ₛ = □ + step(□, ■)
    ■ₛ = ■ + step(□, ■)

    # 4 possible configurations
    if M[□ₛ] == 1 && M[■ₛ] == 1
      □, right[→], □ₛ # make a right turn
    elseif M[□ₛ] == 0 && M[■ₛ] == 1
      □ₛ, →, ■ₛ # continue straight
    elseif M[□ₛ] == 0 && M[■ₛ] == 0
      ■ₛ, left[→], ■ # make a left turn
    else # cross pattern
      ■ₛ, left[→], ■ # left turn policy
    end
  end
  
  # build a closed path
  start = (□, :→, ■)
  next  = move(start)
  path  = [start, next]
  while first(next) ≠ first(start) ||
        last(next) ≠ last(start)
    next = move(next)
    push!(path, next)
  end
  
  path
end

# invert the the mask inside the path
function insideout!(M, path)
  □s, ⬕s   = first.(path), last.(path)
  frontier = collect(zip(□s, ⬕s))
  visited  = falses(size(M))
  visited[□s] .= true
  while !isempty(frontier)
    □, ⬕ = pop!(frontier)
    
    if !visited[⬕]
      # flip color
      M[⬕] = 1 - M[⬕]
      visited[⬕] = true
      
      # update frontier
      δ  = ⬕ - □
      ⬕₁ = ⬕ + δ
      ⬕₂ = ⬕ + CartesianIndex(δ[2],-δ[1])
      ⬕₃ = ⬕ + CartesianIndex(-δ[2],δ[1])
      for ⬕ₛ in [⬕₁, ⬕₂, ⬕₃]
        if !visited[⬕ₛ]
          push!(frontier, (⬕, ⬕ₛ))
        end
      end
    end
  end

  M
end