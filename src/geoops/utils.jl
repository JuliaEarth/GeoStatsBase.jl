#-------------
# AGGREGATION
#-------------

defaultagg(x) = defaultagg(nonmissingtype(elscitype(x)), eltype(x))
defaultagg(::Type{<:Continuous}, ::Type) = _mean
defaultagg(::Type, ::Type{<:AbstractQuantity}) = _mean
defaultagg(::Type, ::Type) = _first

function _mean(x)
  vs = skipmissing(x)
  isempty(vs) ? missing : mean(vs)
end

function _first(x)
  vs = skipmissing(x)
  isempty(vs) ? missing : first(vs)
end

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
  uconvert.(a, x)
end

elunit(x) = typeunit(eltype(x))

typeunit(::Type) = NoUnits
typeunit(::Type{Q}) where {Q<:AbstractQuantity} = unit(Q)
