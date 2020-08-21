# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    EstimationSolution

A solution to a spatial estimation problem.
"""
struct EstimationSolution{𝒟,ℳ,𝒱}
  domain::𝒟
  mean::ℳ
  variance::𝒱
end

# -------------
# VARIABLE API
# -------------

Base.getindex(solution::EstimationSolution, var::Symbol) =
  (mean=solution.mean[var], variance=solution.variance[var])

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
