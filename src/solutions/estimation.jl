# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

"""
    EstimationSolution

A solution to a spatial estimation problem.
"""
struct EstimationSolution{D<:AbstractDomain}
  domain::D
  mean::Dict{Symbol,<:AbstractVector}
  variance::Dict{Symbol,<:AbstractVector}
end

EstimationSolution(domain, mean, variance) =
  EstimationSolution{typeof(domain)}(domain, mean, variance)

"""
    getindex(solution, var)

Return estimation solution for specific variable `var`
as a named tuple (mean=m, variance=v).
"""
function Base.getindex(solution::EstimationSolution, var::Symbol)
  (mean=solution.mean[var], variance=solution.variance[var])
end

function Base.getindex(solution::EstimationSolution{<:RegularGrid}, var::Symbol)
  sz = size(solution.domain)
  M = reshape(solution.mean[var], sz)
  V = reshape(solution.variance[var], sz)
  (mean=M, variance=V)
end

# ------------
# IO methods
# ------------
function Base.show(io::IO, solution::EstimationSolution)
  dim = ndims(solution.domain)
  print(io, "$(dim)D EstimationSolution")
end

function Base.show(io::IO, ::MIME"text/plain", solution::EstimationSolution)
  println(io, solution)
  println(io, "  domain: ", solution.domain)
  print(  io, "  variables: ", join(keys(solution.mean), ", ", " and "))
end
