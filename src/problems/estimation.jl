# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    EstimationProblem(sdata, sdomain, targetvars)

A spatial estimation problem on a given spatial domain `sdomain`
in which the variables to be estimated are listed in `targetvars`.
The data of the problem is stored in spatial data `sdata`.

## Examples

Create an estimation problem for rainfall precipitation measurements:

```julia
julia> EstimationProblem(sdata, sdomain, :precipitation)
```

Create an estimation problem for precipitation and CO₂:

```julia
julia> EstimationProblem(sdata, sdomain, (:precipitation,:CO₂))
```
"""
struct EstimationProblem{S,D} <: AbstractProblem
  # input fields
  sdata::S
  sdomain::D
  targetvars::Dict{Symbol,DataType}

  function EstimationProblem{S,D}(sdata, sdomain, targetvars) where {S,D}
    probvnames = Tuple(keys(targetvars))
    datavnames = name.(variables(sdata))

    @assert !isempty(probvnames) && probvnames ⊆ datavnames "target variables must be present in spatial data"
    @assert coordtype(sdata) == coordtype(sdomain) "data and domain must have the same coordinate type"

    new(sdata, sdomain, targetvars)
  end
end

function EstimationProblem(sdata::S, sdomain::D, targetvarnames::NTuple) where {S,D}
  # build dictionary of target variables
  vars = filter(v -> name(v) ∈ targetvarnames, variables(sdata))
  targetvars = Dict(name(var) => mactype(var) for var in vars)

  EstimationProblem{S,D}(sdata, sdomain, targetvars)
end

EstimationProblem(sdata, sdomain, targetvarname::Symbol) =
  EstimationProblem(sdata, sdomain, (targetvarname,))

"""
    data(problem)

Return the spatial data of the estimation `problem`.
"""
data(problem::EstimationProblem) = problem.sdata

"""
    domain(problem)

Return the spatial domain of the estimation `problem`.
"""
domain(problem::EstimationProblem) = problem.sdomain

"""
    variables(problem)

Return the variable names of the estimation `problem` and their types.
"""
variables(problem::EstimationProblem) = problem.targetvars

# ------------
# IO methods
# ------------
function Base.show(io::IO, problem::EstimationProblem)
  N = ncoords(problem.sdomain)
  print(io, "$(N)D EstimationProblem")
end

function Base.show(io::IO, ::MIME"text/plain", problem::EstimationProblem)
  vars = ["$var ($T)" for (var,T) in problem.targetvars]
  println(io, problem)
  println(io, "  data:      ", problem.sdata)
  println(io, "  domain:    ", problem.sdomain)
  print(  io, "  variables: ", join(vars, ", ", " and "))
end
