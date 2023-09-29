# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

function _skipmissing(fun)
  x -> begin
    vs = skipmissing(x)
    isempty(vs) ? missing : fun(vs)
  end
end
