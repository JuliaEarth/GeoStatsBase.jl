# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    EstimationProblem(sdata, sdomain, vars)

A spatial estimation problem on a given spatial domain `sdomain`
in which the variables to be estimated are listed in `vars`.
The data of the problem is stored in spatial data `sdata`.

## Examples

Create an estimation problem for precipitation measurements:

```julia
julia> EstimationProblem(sdata, sdomain, :precipitation)
```

Create an estimation problem for precipitation and CO₂:

```julia
julia> EstimationProblem(sdata, sdomain, (:precipitation,:CO₂))
```
"""
struct EstimationProblem{S,D} <: Problem
  sdata::S
  sdomain::D
  vars::NamedTuple

  function EstimationProblem{S,D}(sdata, sdomain, vars) where {S,D}
    pvars = keys(vars)
    dvars = Tables.schema(sdata).names
    valid = !isempty(pvars) && pvars ⊆ dvars

    @assert valid "target variables must be present in geospatial data"

    new(sdata, sdomain, vars)
  end
end

function EstimationProblem(sdata::S, sdomain::D, varnames) where {S,D}
  # find variables in geospatial data
  schema = Tables.schema(sdata)
  names = schema.names
  types = nonmissingtype.(schema.types)
  inds = findall(∈(varnames), names)
  vars = (; zip(names[inds], types[inds])...)
  EstimationProblem{S,D}(sdata, sdomain, vars)
end

EstimationProblem(sdata::S, sdomain::D, varname::Symbol) where {S,D} =
  EstimationProblem(sdata, sdomain, (varname,))

"""
    data(problem)

Return the spatial data of the estimation `problem`.
"""
data(problem::EstimationProblem) = problem.sdata

"""
    domain(problem)

Return the spatial domain of the estimation `problem`.
"""
Meshes.domain(problem::EstimationProblem) = problem.sdomain

"""
    variables(problem)

Return the variable names of the estimation `problem` and their types.
"""
variables(problem::EstimationProblem) = problem.vars

# ------------
# IO methods
# ------------
function Base.show(io::IO, problem::EstimationProblem)
  Dim = embeddim(problem.sdomain)
  print(io, "$(Dim)D EstimationProblem")
end

function Base.show(io::IO, ::MIME"text/plain", problem::EstimationProblem)
  pvars = problem.vars
  names = keys(pvars)
  types = values(pvars)
  vars = ["$var ($V)" for (var, V) in zip(names, types)]
  println(io, problem)
  println(io, "  domain:    ", problem.sdomain)
  println(io, "  samples:   ", domain(problem.sdata))
  print(io, "  targets:   ", join(vars, ", ", " and "))
end
