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
