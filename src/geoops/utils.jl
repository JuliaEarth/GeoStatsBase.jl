# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

function _skipmissing(fun)
  x -> begin
    vs = skipmissing(x)
    isempty(vs) ? missing : fun(vs)
  end
end

#-------------
# AGGREGATION
#-------------

defaultagg(x) = defaultagg(nonmissingtype(elscitype(x)), nonmissingtype(eltype(x)))
defaultagg(::Type{<:Continuous}, ::Type) = _skipmissing(mean)
defaultagg(::Type, ::Type{<:AbstractQuantity}) = _skipmissing(mean)
defaultagg(::Type, ::Type) = _skipmissing(first)

#-------
# UNITS
#-------

function uadjust(geotable::AbstractGeoTable)
  dom = domain(geotable)
  tab = values(geotable)
  cols = Tables.columns(tab)
  vars = Tables.columnnames(cols)

  pairs = (var => uadjust(Tables.getcolumn(cols, var)) for var in vars)
  newtab = (; pairs...) |> Tables.materializer(tab)
  georef(newtab, dom)
end

uadjust(x) = uadjust(elunit(x), x)
uadjust(::Units, x) = x
function uadjust(u::AffineUnits, x)
  a = absoluteunit(u)
  [ismissing(v) ? missing : uconvert(a, v) for v in x]
end

elunit(x) = typeunit(nonmissingtype(eltype(x)))

typeunit(::Type) = NoUnits
typeunit(::Type{Q}) where {Q<:AbstractQuantity} = unit(Q)
