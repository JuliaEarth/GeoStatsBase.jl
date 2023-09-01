# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    EstimationProblem(data, domain, vars)

A geospatial estimation problem on a given geospatial `domain`
in which the variables to be estimated are listed in `vars`.
The data of the problem is stored in geospatial `data`.

## Examples

Create an estimation problem for precipitation measurements:

```julia
julia> EstimationProblem(data, domain, :precipitation)
```

Create an estimation problem for precipitation and CO₂:

```julia
julia> EstimationProblem(data, domain, (:precipitation,:CO₂))
```
"""
struct EstimationProblem{S,D} <: Problem
  data::S
  domain::D
  vars::NamedTuple

  function EstimationProblem{S,D}(data, domain, vars) where {S,D}
    pvars = keys(vars)
    dvars = Tables.schema(data).names
    valid = !isempty(pvars) && pvars ⊆ dvars

    @assert valid "target variables must be present in geospatial data"

    new(data, domain, vars)
  end
end

function EstimationProblem(data::S, domain::D, varnames) where {S,D}
  # find variables in geospatial data
  schema = Tables.schema(data)
  names = schema.names
  types = nonmissingtype.(schema.types)
  inds = findall(∈(varnames), names)
  vars = (; zip(names[inds], types[inds])...)
  EstimationProblem{S,D}(data, domain, vars)
end

EstimationProblem(data::S, domain::D, varname::Symbol) where {S,D} = EstimationProblem(data, domain, (varname,))

"""
    data(problem)

Return the spatial data of the estimation `problem`.
"""
data(problem::EstimationProblem) = problem.data

"""
    domain(problem)

Return the spatial domain of the estimation `problem`.
"""
domain(problem::EstimationProblem) = problem.domain

"""
    variables(problem)

Return the variable names of the estimation `problem` and their types.
"""
variables(problem::EstimationProblem) = problem.vars

# ------------
# IO methods
# ------------
function Base.show(io::IO, problem::EstimationProblem)
  Dim = embeddim(problem.domain)
  print(io, "$(Dim)D EstimationProblem")
end

function Base.show(io::IO, ::MIME"text/plain", problem::EstimationProblem)
  pvars = problem.vars
  vars = ["$var ($V)" for (var, V) in pairs(pvars)]
  println(io, problem)
  println(io, "  domain:    ", problem.domain)
  println(io, "  samples:   ", domain(problem.data))
  print(io, "  targets:   ", join(vars, ", ", " and "))
end
