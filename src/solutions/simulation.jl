# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    SimulationSolution

A solution to a spatial simulation problem.
"""
struct SimulationSolution{𝒟,ℛ}
  domain::𝒟
  realizations::ℛ
  nreals::Int

  function SimulationSolution{𝒟,ℛ}(domain, realizations) where {𝒟,ℛ}
    n = [length(r) for (var, r) in realizations]
    @assert length(unique(n)) == 1 "number of realizations must be unique"
    new(domain, realizations, n[1])
  end
end

SimulationSolution(domain::𝒟, realizations::ℛ) where {𝒟,ℛ} =
  SimulationSolution{𝒟,ℛ}(domain, realizations)

# -------------
# VARIABLE API
# -------------

Base.getindex(solution::SimulationSolution, var::Symbol) =
  solution.realizations[var]

# -------------
# ITERATOR API
# -------------

Base.iterate(solution::SimulationSolution, state=1) =
  state > solution.nreals ? nothing : (solution[state], state + 1)
Base.length(solution::SimulationSolution) = solution.nreals

# --------------
# INDEXABLE API
# --------------

function Base.getindex(solution::SimulationSolution, ind::Int)
  sdomain = solution.domain
  sreals  = solution.realizations
  idata   = DataFrame([var => reals[ind] for (var, reals) in sreals])
  georef(idata, sdomain)
end
Base.getindex(solution::SimulationSolution, inds::AbstractVector{Int}) =
  [getindex(solution, ind) for ind in inds]
Base.firstindex(solution::SimulationSolution) = 1
Base.lastindex(solution::SimulationSolution) = length(solution)

# ------------
# IO methods
# ------------
function Base.show(io::IO, solution::SimulationSolution)
  N = ncoords(solution.domain)
  print(io, "$(N)D SimulationSolution")
end

function Base.show(io::IO, ::MIME"text/plain", solution::SimulationSolution)
  println(io, solution)
  println(io, "  domain: ", solution.domain)
  println(io, "  variables: ", join(keys(solution.realizations), ", ", " and "))
  print(  io, "  N° reals:  ", solution.nreals)
end
