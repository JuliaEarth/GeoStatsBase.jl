# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
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
struct EstimationProblem{S,D,M} <: AbstractProblem
  # input fields
  sdata::S
  sdomain::D
  mapper::M
  targetvars::Dict{Symbol,DataType}

  # state fields
  mappings::Dict{Symbol,Dict{Int,Int}}

  function EstimationProblem{S,D,M}(sdata, sdomain, targetvars, mapper) where {S,D,M}
    probvnames = Tuple(keys(targetvars))
    datavnames = name.(variables(sdata))

    @assert !isempty(probvnames) && probvnames ⊆ datavnames "target variables must be present in spatial data"
    @assert coordtype(sdata) == coordtype(sdomain) "data and domain must have the same coordinate type"

    mappings = map(sdata, sdomain, probvnames, mapper)

    new(sdata, sdomain, mapper, targetvars, mappings)
  end
end

function EstimationProblem(sdata::S, sdomain::D, targetvarnames::NTuple;
                           mapper::M=NearestMapper()) where {S,D,M}
  # build dictionary of target variables
  vars = filter(v -> name(v) ∈ targetvarnames, variables(sdata))
  targetvars = Dict(name(var) => type(var) for var in vars)

  EstimationProblem{S,D,M}(sdata, sdomain, targetvars, mapper)
end

EstimationProblem(sdata, sdomain, targetvarname::Symbol; mapper=NearestMapper()) =
  EstimationProblem(sdata, sdomain, (targetvarname,); mapper=mapper)

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
    mapper(problem)

Return the mapper of the estimation `problem`.
"""
mapper(problem::EstimationProblem) = problem.mapper

"""
    variables(problem)

Return the variable names of the estimation `problem` and their types.
"""
variables(problem::EstimationProblem) = problem.targetvars

"""
    datamap(problem, targetvar)

Return the mapping from domain locations to data locations for the
`targetvar` of the `problem`.
"""
datamap(problem::EstimationProblem, var::Symbol) = problem.mappings[var]

"""
    datamap(problem)

Return the mappings from domain locations to data locations for all
the variables of the `problem`.
"""
datamap(problem::EstimationProblem) = problem.mappings

# ------------
# IO methods
# ------------
function Base.show(io::IO, problem::EstimationProblem)
  dim = ndims(problem.sdomain)
  print(io, "$(dim)D EstimationProblem")
end

function Base.show(io::IO, ::MIME"text/plain", problem::EstimationProblem)
  vars = ["$var ($T)" for (var,T) in problem.targetvars]
  println(io, problem)
  println(io, "  data:      ", problem.sdata)
  println(io, "  domain:    ", problem.sdomain)
  print(  io, "  variables: ", join(vars, ", ", " and "))
end
