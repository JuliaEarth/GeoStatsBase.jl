defaultagg(v) = elscitype(v) <: Continuous ? _mean : _first

function _mean(xs)
  vs = skipmissing(xs)
  isempty(vs) ? missing : mean(vs)
end

function _first(xs)
  vs = skipmissing(xs)
  isempty(vs) ? missing : first(vs)
end
