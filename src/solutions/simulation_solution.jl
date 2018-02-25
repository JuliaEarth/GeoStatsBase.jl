# ------------------------------------------------------------------
# Copyright (c) 2017, Júlio Hoffimann Mendes <juliohm@stanford.edu>
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

"""
    SimulationSolution

A solution to a spatial simulation problem.
"""
struct SimulationSolution{D<:AbstractDomain} <: AbstractSolution
  domain::D
  realizations::Dict{Symbol,Vector{Vector}}
end

SimulationSolution(domain, realizations) =
  SimulationSolution{typeof(domain)}(domain, realizations)

"""
    domain(solution)

Return the domain of a simulation `solution`.
"""
domain(solution::SimulationSolution) = solution.domain

"""
    digest(solution)

Convert solution to a dictionary-like format where the
keys of the dictionary are the variables of the problem.
"""
function digest(solution::SimulationSolution)
  # solution variables
  variables = collect(keys(solution.realizations))

  # output dictionary
  Dict(var => solution.realizations[var] for var in variables)
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
