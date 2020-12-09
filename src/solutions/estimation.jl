# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    EstimationSolution

A solution to a spatial estimation problem.
"""
struct EstimationSolution{D,M,V}
  domain::D
  mean::M
  variance::V
end

# -------------
# VARIABLE API
# -------------

function Base.getindex(solution::EstimationSolution, var::Symbol)
  vars = (var, Symbol(var,"var"))
  vals = (solution.mean[var], solution.variance[var])
  georef((; zip(vars, vals)...), solution.domain)
end

# ------------
# IO methods
# ------------
function Base.show(io::IO, solution::EstimationSolution)
  N = ncoords(solution.domain)
  print(io, "$(N)D EstimationSolution")
end

function Base.show(io::IO, ::MIME"text/plain", solution::EstimationSolution)
  println(io, solution)
  println(io, "  domain: ", solution.domain)
  print(  io, "  variables: ", join(keys(solution.mean), ", ", " and "))
end
