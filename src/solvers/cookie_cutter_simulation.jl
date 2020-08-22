# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------
# TODO: review
"""
    CookieCutter(master, others)

A cookie-cutter simulation solver.

## Parameters

* `master` - Master simulation solver (a.k.a. facies solver)
* `others` - A list of pairs mapping categories to solvers

## Examples

Simulate lithology facies with image quilting and fill property
with direct Gaussian simulation:

```julia
julia> fsolver  = ImgQuilt(:facies => (TI=Strebelle, template=(30,30,1)))
julia> psolver₀ = DirectGaussSim(:property => (variogram=SphericalVariogram(range=10.),))
julia> psolver₁ = DirectGaussSim(:property => (variogram=SphericalVariogram(range=20.),))
julia> solver   = CookieCutter(fsolver, [0 => psolver₀, 1 => psolver₁])
```
"""
struct CookieCutter <: AbstractSimulationSolver
  master::AbstractSimulationSolver
  others::Dict{Number,AbstractSimulationSolver}
end

function solve(problem::SimulationProblem, solver::CookieCutter)
  # retrieve problem info
  pdata   = data(problem)
  pdomain = domain(problem)
  pvars   = variables(problem)
  preals  = nreals(problem)
  pmapper = mapper(problem)

  # master variable
  mvars = variables(solver.master)
  @assert length(mvars) == 1 "one single variable must be specified in master solver"
  mvar = mvars[1]
  @assert mvar ∈ keys(pvars) "invalid variable in master solver"
  mtype = pvars[mvar]

  # other variables
  ovars = Tuple(var => V for (var, V) in pvars if var ≠ mvar)
  @assert length(ovars) > 0 "cookie-cutter requires problem with more than one target variable"

  # define master and others problem
  if hasdata(problem)
    mproblem = SimulationProblem(pdata, pdomain, mvar, preals, mapper=pmapper)
    oproblem = SimulationProblem(pdata, pdomain, first.(ovars), preals, mapper=pmapper)
  else
    mproblem = SimulationProblem(pdomain, mvar => mtype, preals, mapper=pmapper)
    oproblem = SimulationProblem(pdomain, ovars, preals, mapper=pmapper)
  end

  # realizations of master variable
  msol = solve(mproblem, solver.master)
  mreals = msol[mvar]

  # pre-allocate memory for realizations
  reals = Dict(var => [Vector{V}(undef, nelms(pdomain)) for i in 1:preals] for (var,V) in ovars)

  # solve other problems
  for (mval, osolver) in solver.others
    osol = solve(oproblem, osolver)

    # cookie-cutter step
    for (var, V) in ovars
      vreals = osol[var]
      for i in 1:preals
        mask = mreals[i] .== mval
        reals[var][i][mask] .= vreals[i][mask]
      end
    end
  end

  realizations = merge(reals, Dict(mvar => mreals))

  SimulationSolution(pdomain, realizations)
end

# ------------
# IO methods
# ------------
function Base.show(io::IO, solver::CookieCutter)
  print(io, "CookieCutter")
end

function Base.show(io::IO, ::MIME"text/plain", solver::CookieCutter)
  mvar = variables(solver.master)[1]
  println(io, solver)
  println(io, "  └─", mvar, " ⇨ ", solver.master)
  for (val, osolver) in solver.others
    println(io, "    └─", val, " ⇨ ", osolver)
  end
end
