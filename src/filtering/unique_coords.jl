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
function is `mean` for continuous variables and `first`
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
  # retrieve filtering info
  vars   = variables(sdata)
  tol    = filt.tol
  metric = filt.metric
  aggreg = filt.aggreg
  for (var, V) in vars
    if var ∉ keys(aggreg)
      ST = scitype(sdata[1,var])
      aggreg[var] = ST <: Continuous ? mean_aggreg : first_aggreg
    end
  end

  # find unique coordinates via ball partitioning
  p = partition(sdata, BallPartitioner(tol, metric=metric))

  # construct new point set data
  locs = Vector{Int}()
  dict = OrderedDict{Symbol,Vector{V} where V}()
  for (var, V) in vars
    dict[var] = Vector{V}()
  end
  for s in subsets(p)
    i = s[1] # select any location
    if length(s) > 1
      # aggregate variables
      for (var, V) in vars
        push!(dict[var], aggreg[var](sdata[s,var]))
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

function mean_aggreg(xs)
  vs = skipmissing(xs)
  isempty(vs) ? missing : mean(vs)
end

function first_aggreg(xs)
  vs = skipmissing(xs)
  isempty(vs) ? missing : first(vs)
end
