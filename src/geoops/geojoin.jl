# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

const KINDS = [:left, :inner]

"""
    geojoin(geotable₁, geotable₂, var₁ => agg₁, ..., varₙ => aggₙ; kind=:left, pred=intersects)

Joins `geotable₁` with `geotable₂` using a certain `kind` of join and predicate function `pred`
that takes two geometries and returns a boolean (`(g1, g2) -> g1 ⊆ g2`).

Whenever two or more matches are encountered, aggregate `varᵢ` with aggregation function `aggᵢ`.
If no aggregation function is provided for a variable, then the aggregation function will be
selected according to the scientific types: `mean` for continuous and `first` otherwise.

## Kinds

* `:left` - Returns all rows of `geotable₁` and fills non-matching rows of `geotable₂` with missing values.
* `:inner` - Returns only the rows of `geotable₁` with matches in `geotable₂`.

# Examples

```julia
geojoin(gtb1, gtb2)
geojoin(gtb1, gtb2, 1 => mean)
geojoin(gtb1, gtb2, :a => mean, :b => std)
geojoin(gtb1, gtb2, "a" => mean, pred=issubset)
```
"""
geojoin(gtb1::AbstractGeoTable, gtb2::AbstractGeoTable; kwargs...) =
  _geojoin(gtb1, gtb2, NoneSpec(), Function[]; kwargs...)

geojoin(gtb1::AbstractGeoTable, gtb2::AbstractGeoTable, pairs::Pair{C,<:Function}...; kwargs...) where {C<:Col} =
  _geojoin(gtb1, gtb2, colspec(first.(pairs)), collect(Function, last.(pairs)); kwargs...)

function _geojoin(
  gtb1::AbstractGeoTable,
  gtb2::AbstractGeoTable,
  colspec::ColSpec,
  aggfuns::Vector{Function};
  kind=:left,
  pred=intersects
)
  if kind ∉ KINDS
    throw(ArgumentError("invalid kind of join, use one these $KINDS"))
  end

  # make variable names unique
  vars1 = Tables.schema(values(gtb1)).names
  vars2 = Tables.schema(values(gtb2)).names
  if !isdisjoint(vars1, vars2)
    # repeated variable names
    vars = vars1 ∩ vars2
    pairs = map(vars) do var
      newvar = var
      while newvar ∈ vars1
        newvar = Symbol(newvar, :_)
      end
      var => newvar
    end
    gtb2 = gtb2 |> Rename(pairs...)
  end

  if kind === :inner
    _innerjoin(gtb1, gtb2, colspec, aggfuns, pred)
  else
    _leftjoin(gtb1, gtb2, colspec, aggfuns, pred)
  end
end

function _leftjoin(gtb1, gtb2, colspec, aggfuns, pred)
  dom1 = domain(gtb1)
  dom2 = domain(gtb2)
  tab1 = values(gtb1)
  tab2 = values(gtb2)
  cols1 = Tables.columns(tab1)
  cols2 = Tables.columns(tab2)
  vars1 = Tables.columnnames(cols1)
  vars2 = Tables.columnnames(cols2)

  # aggregation functions
  svars = choose(colspec, vars2)
  agg = Dict(zip(svars, aggfuns))
  for var in vars2
    if !haskey(agg, var)
      v = Tables.getcolumn(cols2, var)
      agg[var] = defaultagg(v)
    end
  end

  # rows to join
  nrows = nrow(gtb1)
  ncols = ncol(gtb2) - 1
  types = Tables.schema(tab2).types
  rows = [[T[] for T in types] for _ in 1:nrows]
  for (i1, geom1) in enumerate(dom1)
    for (i2, geom2) in enumerate(dom2)
      if pred(geom1, geom2)
        row = Tables.subset(tab2, i2)
        for j in 1:ncols
          v = Tables.getcolumn(row, j)
          push!(rows[i1][j], v)
        end
      end
    end
  end

  # generate joined column
  function gencol(j, var)
    map(1:nrows) do i
      vs = rows[i][j]
      if isempty(vs)
        missing
      elseif length(vs) == 1
        first(vs)
      else
        agg[var](vs)
      end
    end
  end

  pairs1 = (var => Tables.getcolumn(cols1, var) for var in vars1)
  pairs2 = (var => gencol(j, var) for (j, var) in enumerate(vars2))
  newtab = (; pairs1..., pairs2...) |> Tables.materializer(tab1)

  georef(newtab, dom1)
end

function _innerjoin(gtb1, gtb2, colspec, aggfuns, pred)
  dom1 = domain(gtb1)
  dom2 = domain(gtb2)
  tab1 = values(gtb1)
  tab2 = values(gtb2)
  cols1 = Tables.columns(tab1)
  cols2 = Tables.columns(tab2)
  vars1 = Tables.columnnames(cols1)
  vars2 = Tables.columnnames(cols2)

  # aggregation functions
  svars = choose(colspec, vars2)
  agg = Dict(zip(svars, aggfuns))
  for var in vars2
    if !haskey(agg, var)
      v = Tables.getcolumn(cols2, var)
      agg[var] = defaultagg(v)
    end
  end

  nrows = nrow(gtb1)
  ncols = ncol(gtb2) - 1
  types = Tables.schema(tab2).types
  # rows to join from gtb2
  rows = [[T[] for T in types] for _ in 1:nrows]
  # row indices to preserve from gtb1
  inds = Int[]
  for (i1, geom1) in enumerate(dom1)
    for (i2, geom2) in enumerate(dom2)
      if pred(geom1, geom2)
        i1 ∉ inds && push!(inds, i1)
        row = Tables.subset(tab2, i2)
        for j in 1:ncols
          v = Tables.getcolumn(row, j)
          push!(rows[i1][j], v)
        end
      end
    end
  end

  # generate joined column
  function gencol(j, var)
    map(inds) do i
      vs = rows[i][j]
      if length(vs) > 1
        agg[var](vs)
      else
        first(vs)
      end
    end
  end

  sub = Tables.subset(tab1, inds)
  cols = Tables.columns(sub)
  pairs1 = (var => Tables.getcolumn(cols, var) for var in vars1)
  pairs2 = (var => gencol(j, var) for (j, var) in enumerate(vars2))
  newtab = (; pairs1..., pairs2...) |> Tables.materializer(tab1)

  georef(newtab, view(dom1, inds))
end

# utilities
defaultagg(x) = defaultagg(nonmissingtype(elscitype(x)))
defaultagg(::Type{<:Continuous}) = _mean
defaultagg(::Type) = _first

function _mean(x)
  vs = skipmissing(x)
  isempty(vs) ? missing : mean(vs)
end

function _first(x)
  vs = skipmissing(x)
  isempty(vs) ? missing : first(vs)
end
