# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    EstimationProblem(geotable, domain, vars)

A geospatial estimation problem on a given geospatial `domain`
in which the variables to be estimated are listed in `vars`.
The data of the problem is stored in `geotable`.

## Examples

Create an estimation problem for precipitation measurements:

```julia
julia> EstimationProblem(geotable, domain, :precipitation)
```

Create an estimation problem for precipitation and CO₂:

```julia
julia> EstimationProblem(geotable, domain, (:precipitation,:CO₂))
```
"""
struct EstimationProblem{GT,D} <: Problem
  geotable::GT
  domain::D
  vars::NamedTuple

  function EstimationProblem{GT,D}(geotable, domain, vars) where {GT,D}
    pvars = keys(vars)
    dvars = Tables.schema(geotable).names
    valid = !isempty(pvars) && pvars ⊆ dvars

    @assert valid "target variables must be present in geospatial data"

    new(geotable, domain, vars)
  end
end

function EstimationProblem(geotable::GT, domain::D, varnames) where {GT,D}
  # find variables in geospatial data
  schema = Tables.schema(geotable)
  names = schema.names
  types = nonmissingtype.(schema.types)
  inds = findall(∈(varnames), names)
  vars = (; zip(names[inds], types[inds])...)
  EstimationProblem{GT,D}(geotable, domain, vars)
end

EstimationProblem(geotable::GT, domain::D, varname::Symbol) where {GT,D} = EstimationProblem(geotable, domain, (varname,))

"""
    data(problem)

Return the spatial data of the estimation `problem`.
"""
data(problem::EstimationProblem) = problem.geotable

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
  println(io, "  samples:   ", domain(problem.geotable))
  print(io, "  targets:   ", join(vars, ", ", " and "))
end
