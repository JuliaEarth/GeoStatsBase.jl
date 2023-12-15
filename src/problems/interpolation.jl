# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    InterpProblem(data, domain, vars)

A geospatial interpolation problem on a given geospatial `domain`
in which the variables to be estimated are listed in `vars`.
The data of the problem is stored in geospatial `data`.

## Examples

Create an interpolation problem for precipitation measurements:

```julia
julia> InterpProblem(data, domain, :precipitation)
```

Create an interpolation problem for precipitation and CO₂:

```julia
julia> InterpProblem(data, domain, (:precipitation,:CO₂))
```
"""
struct InterpProblem{S,D} <: Problem
  data::S
  domain::D
  vars::NamedTuple

  function InterpProblem{S,D}(data, domain, vars) where {S,D}
    pvars = keys(vars)
    dvars = Tables.schema(data).names
    valid = !isempty(pvars) && pvars ⊆ dvars

    @assert valid "target variables must be present in geospatial data"

    new(data, domain, vars)
  end
end

function InterpProblem(data::S, domain::D, varnames) where {S,D}
  # find variables in geospatial data
  schema = Tables.schema(data)
  names = schema.names
  types = nonmissingtype.(schema.types)
  inds = findall(∈(varnames), names)
  vars = (; zip(names[inds], types[inds])...)
  InterpProblem{S,D}(data, domain, vars)
end

InterpProblem(data::S, domain::D, varname::Symbol) where {S,D} = InterpProblem(data, domain, (varname,))

"""
    data(problem)

Return the spatial data of the interpolation `problem`.
"""
data(problem::InterpProblem) = problem.data

"""
    domain(problem)

Return the spatial domain of the interpolation `problem`.
"""
domain(problem::InterpProblem) = problem.domain

"""
    variables(problem)

Return the variable names of the interpolation `problem` and their types.
"""
variables(problem::InterpProblem) = problem.vars

# ------------
# IO methods
# ------------
function Base.show(io::IO, problem::InterpProblem)
  Dim = embeddim(problem.domain)
  print(io, "$(Dim)D InterpProblem")
end

function Base.show(io::IO, ::MIME"text/plain", problem::InterpProblem)
  pvars = problem.vars
  vars = ["$var ($V)" for (var, V) in pairs(pvars)]
  println(io, problem)
  println(io, "  domain:    ", problem.domain)
  println(io, "  samples:   ", domain(problem.data))
  print(io, "  targets:   ", join(vars, ", ", " and "))
end
