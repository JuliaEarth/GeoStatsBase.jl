# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

"""
    SimulationSolution

A solution to a spatial simulation problem.
"""
struct SimulationSolution{D<:AbstractDomain}
  domain::D
  realizations::Dict{Symbol,Vector{<:AbstractVector}}
end

SimulationSolution(domain, realizations) =
  SimulationSolution{typeof(domain)}(domain, realizations)

"""
    getindex(solution, var)

Return simulation solution for specific variable `var`
as a vector of realizations.
"""
function Base.getindex(solution::SimulationSolution, var::Symbol)
  solution.realizations[var]
end

function Base.getindex(solution::SimulationSolution{<:RegularGrid}, var::Symbol)
  sz = size(solution.domain)
  [reshape(real, sz) for real in solution.realizations[var]]
end

# ------------
# IO methods
# ------------
function Base.show(io::IO, solution::SimulationSolution)
  dim = ndims(solution.domain)
  print(io, "$(dim)D SimulationSolution")
end

function Base.show(io::IO, ::MIME"text/plain", solution::SimulationSolution)
  println(io, solution)
  println(io, "  domain: ", solution.domain)
  print(  io, "  variables: ", join(keys(solution.realizations), ", ", " and "))
end
