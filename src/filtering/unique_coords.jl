# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    UniqueCoordsFilter([options])

A filter method to retain locations in spatial objects
with unique coordinates.

## Options

* `aggreg` - Dictionary with aggregation function for each variable
* `metric` - Metric (default to `Euclidean()`)
* `tol`    - Tolerance for coordinates distance (default to `1e-6`)

Duplicates of a variable `var` are aggregated with
aggregation function `aggreg[var]`. Default aggregation
function is `mean` for numerical variables and `first`
otherwise.

Coordinates are unique according to `metric` and `tol`.
"""
struct UniqueCoordsFilter{M<:Metric,T<:Real} <: AbstractFilter
  aggreg::Dict{Symbol,Function}
  metric::M
  tol::T
end

UniqueCoordsFilter(; aggreg=Dict{Symbol,Function}(),
                     metric=Euclidean(), tol=1e-6) =
  UniqueCoordsFilter{typeof(metric),typeof(tol)}(aggreg, metric, tol)

function Base.filter(sdata::AbstractData, filt::UniqueCoordsFilter)
  # retrieve info
  aggreg = filt.aggreg
  metric = filt.metric
  tol    = filt.tol
  vars   = variables(sdata)

  # find unique coordinates via ball partitioning
  partitioner = BallPartitioner(tol, metric=metric)
  p = partition(sdata, partitioner)

  # auxiliary variables
  locs = Vector{Int}()
  dict = OrderedDict([var => Vector{V}() for (var, V) in vars])
  aggr = Dict{Symbol,Function}()
  for (var, V) in vars
    aggr[var] = get(aggreg, var, V <: Number ? mean : first)
  end

  # construct new point set data
  for s in subsets(p)
    i = s[1] # select any location
    if length(s) > 1
      # aggregate variables
      for (var, V) in vars
        aggfun = aggr[var]
        push!(dict[var], aggfun(sdata[s,var]))
      end
    else
      # copy location
      for (var, V) in vars
        push!(dict[var], sdata[i,var])
      end
    end
    push!(locs, i)
  end

  PointSetData(dict, coordinates(sdata, locs))
end
