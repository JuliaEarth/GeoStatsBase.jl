defaultagg(v) = defaultagg(nonmissingtype(elscitype(v)))
defaultagg(::Type{<:Continuous}) = _mean
defaultagg(::Type) = _first

function _mean(xs)
  vs = skipmissing(xs)
  isempty(vs) ? missing : mean(vs)
end

function _first(xs)
  vs = skipmissing(xs)
  isempty(vs) ? missing : first(vs)
end
