# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

macro groupby(data, cols...)
  :(_groupby($(esc(data)), $(cols...)))
end

_groupby(data::Data, spec) = _groupby(data, colspec(spec))
_groupby(data::Data, cols::T...) where {T<:Col} = 
  _groupby(data, colspec(cols))

function _groupby(data::Data, colspec::ColSpec)
  table = values(data)

  cols   = Tables.columns(table)
  names  = Tables.columnnames(cols)
  snames = choose(colspec, names)

  scolumns = [Tables.getcolumn(cols, nm) for nm in snames]

  srows = collect(zip(scolumns...))
  urows = unique(srows)
  inds  = map(row -> findall(===(row), srows), urows)

  metadata = Dict(:values => urows)
  Partition(data, inds, metadata)
end
