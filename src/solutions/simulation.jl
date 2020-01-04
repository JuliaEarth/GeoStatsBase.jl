# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    SimulationSolution

A solution to a spatial simulation problem.
"""
struct SimulationSolution{D<:AbstractDomain}
  domain::D
  realizations::Dict{Symbol,Vector{<:AbstractVector}}
  nreals::Int

  function SimulationSolution{D}(domain, realizations) where {D}
    n = [length(r) for (var, r) in realizations]
    @assert length(unique(n)) == 1 "number of realizations must be unique"
    new(domain, realizations, n[1])
  end
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

#---------------
# ITERATOR API
#---------------

"""
    iterate(solution, state=1)

Iterate over realizations in simulation `solution`.
"""
Base.iterate(solution::SimulationSolution, state=1) =
  state > solution.nreals ? nothing : (solution[state], state + 1)

"""
    length(solution)

Return the number of realizations in simulation `solution`.
"""
Base.length(solution::SimulationSolution) = solution.nreals

#----------------
# INDEXABLE API
#----------------

"""
    getindex(solution, ind)

Return the `ind`-th realization of simulation `solution`.
"""
function Base.getindex(solution::SimulationSolution, ind::Int)
  sdomain = solution.domain
  sreals  = solution.realizations
  idata   = Dict(var => reals[ind] for (var, reals) in sreals)
  georeference(idata, sdomain)
end

Base.getindex(solution::SimulationSolution, inds::AbstractVector{Int}) =
  [getindex(solution, ind) for ind in inds]

"""
    firstindex(solution)

Return the first index of simulation `solution`.
"""
Base.firstindex(solution::SimulationSolution) = 1

"""
    lastindex(solution)

Return the last index of simulation `solution`.
"""
Base.lastindex(solution::SimulationSolution) = length(solution)

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
  println(io, "  variables: ", join(keys(solution.realizations), ", ", " and "))
  print(  io, "  N° reals:  ", solution.nreals)
end
