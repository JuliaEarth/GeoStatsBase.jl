# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

"""
    EstimationSolution

A solution to a spatial estimation problem.
"""
struct EstimationSolution{D<:AbstractDomain} <: AbstractSolution
  domain::D
  mean::Dict{Symbol,Vector}
  variance::Dict{Symbol,Vector}
end

EstimationSolution(domain, mean, variance) =
  EstimationSolution{typeof(domain)}(domain, mean, variance)

"""
    domain(solution)

Return the domain of the estimation `solution`.
"""
domain(solution::EstimationSolution) = solution.domain

"""
    digest(solution)

Convert solution to a dictionary-like format where the
keys of the dictionary are the variables of the problem.
"""
function digest(solution::EstimationSolution)
  # solution variables
  variables = keys(solution.mean)

  # build dictionary pairs
  pairs = []
  for var in variables
    M = solution.mean[var]
    V = solution.variance[var]

    push!(pairs, var => Dict(:mean => M, :variance => V))
  end

  # output dictionary
  Dict(pairs)
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
