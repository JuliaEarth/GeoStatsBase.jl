# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

const KINDS = [:left]

function geojoin(gtb1::AbstractGeoTable, gtb2::AbstractGeoTable; kind=:left, pred=intersects, makeunique=false)
  if kind ∉ KINDS
    throw(ArgumentError("invalid join kind, use one these $KINDS"))
  end

  vars1 = Tables.schema(values(gtb1)).names
  vars2 = Tables.schema(values(gtb2)).names
  if !isdisjoint(vars1, vars2)
    if makeunique
      vars = vars1 ∩ vars2
      pairs = map(vars) do var
        newvar = var
        while newvar ∈ vars1
          newvar = Symbol(newvar, :_)
        end
        var => newvar
      end
      gtb2 = gtb2 |> Rename(gtb2, pairs...)
    else
      throw(ArgumentError("the geotables must be different variables"))
    end
  end

  _leftjoin(gtb1, gtb2, pred)
end

function _leftjoin(gtb1, gtb2, pred)
  dom1 = domain(gtb1)
  dom2 = domain(gtb2)
  tab1 = values(gtb1)
  tab2 = values(gtb2)
  sch1 = Tables.schema(tab1)
  sch2 = Tables.schema(tab2)
  vars1 = sch1.names
  vars2 = sch2.names

  # rows to join
  types = sch2.types
  ncols = length(vars1)
  nrows = nelements(dom1)
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
  function gencol(j)
    map(1:nrows) do i
      vs = rows[i][j]
      if isempty(vs)
        missing
      elseif length(vs) == 1
        first(vs)
      else
        agg = defaultagg(vs)
        agg(vs)
      end
    end
  end

  cols = Tables.columns(tab1)
  pairs1 = (var => Tables.getcolumn(cols, var) for var in vars1)
  pairs2 = (var => gencol(j) for (j, var) in enumerate(vars2))
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
