# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

const KINDS = [:left]

geojoin(gtb1::AbstractGeoTable, gtb2::AbstractGeoTable; kwargs...) =
  _geojoin(gtb1, gtb2, NoneSpec(), Function[]; kwargs...)

geojoin(gtb1::AbstractGeoTable, gtb2::AbstractGeoTable, pairs::Pair{C,<:Function}...; kwargs...) where {C<:Col} =
  _geojoin(gtb1, gtb2, colspec(first.(pairs)), collect(last.(pairs)); kwargs...)

function _geojoin(
  gtb1::AbstractGeoTable,
  gtb2::AbstractGeoTable,
  colspec::ColSpec,
  aggfuns::Vector{<:Function};
  kind=:left,
  pred=intersects
)
  if kind ∉ KINDS
    throw(ArgumentError("invalid join kind, use one these $KINDS"))
  end

  # make column names unique
  vars1 = Tables.schema(values(gtb1)).names
  vars2 = Tables.schema(values(gtb2)).names
  if !isdisjoint(vars1, vars2)
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

  # aggregation functions
  agg = Dict(zip(choose(colspec, vars2), aggfuns))

  _leftjoin(gtb1, gtb2, agg, pred)
end

function _leftjoin(gtb1, gtb2, agg, pred)
  dom1 = domain(gtb1)
  dom2 = domain(gtb2)
  tab1 = values(gtb1)
  tab2 = values(gtb2)
  cols1 = Tables.columns(tab1)
  cols2 = Tables.columns(tab2)
  vars1 = Tables.columnnames(cols1)
  vars2 = Tables.columnnames(cols2)

  # aggregation functions
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
  for (i, geom1) in enumerate(dom1)
    for (ind, geom2) in enumerate(dom2)
      if pred(geom1, geom2)
        row = Tables.subset(tab2, ind)
        for j in 1:ncols
          v = Tables.getcolumn(row, j)
          push!(rows[i][j], v)
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
