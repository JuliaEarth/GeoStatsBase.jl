# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

const VarType = Pair{Symbol,DataType}
const VarOrVarType = Union{Symbol,VarType}

"""
    SimulationProblem(geotable, domain, vars, nreals)
    SimulationProblem(domain, vars, nreals)

A geospatial simulation problem on a given geospatial `domain`
in which the variables to be simulated are listed in `vars`.

For conditional simulation, the data of the problem is stored in
`geotable`.

For unconditional simulation, a list of pairs `vars` must be
provided mapping variable names to their types.

In both cases, a number `nreals` of realizations is requested.

## Examples

Create a conditional simulation problem for porosity and permeability
with 100 realizations:

```julia
julia> SimulationProblem(geotable, domain, (:porosity,:permeability), 100)
```

Create an unconditional simulation problem for porosity and facies type
with 100 realizations:

```julia
julia> SimulationProblem(domain, (:porosity => Float64, :facies => Int), 100)
```
"""
struct SimulationProblem{GT,D} <: Problem
  geotable::GT
  domain::D
  vars::NamedTuple
  nreals::Int

  function SimulationProblem{GT,D}(geotable, domain, vars, nreals) where {GT,D}
    @assert !isempty(vars) "target variables must be specified"
    @assert nreals > 0 "number of realizations must be positive"
    new(geotable, domain, vars, nreals)
  end
end

function SimulationProblem(geotable::GT, domain::D, vars::NTuple{N,VarOrVarType}, nreals::Int) where {GT,D,N}
  schema = Tables.schema(geotable)
  names = schema.names
  types = nonmissingtype.(schema.types)
  dvars = (; zip(names, types)...)

  # pairs with variable names and types
  varstypes = map(vars) do vt
    if vt isa Symbol # for variables without type, find the type in geospatial data
      var = vt
      if var ∈ keys(dvars)
        var => dvars[var]
      else
        @error "please specify the type of target variable $var"
      end
    else # for variables with type, make sure the type is valid
      var, V = vt
      if var ∈ keys(dvars)
        U = dvars[var]
        @assert U <: V "type $V for variable $var cannot hold values of type $U in geospatial data"
      end
      vt
    end
  end

  SimulationProblem{GT,D}(geotable, domain, NamedTuple(varstypes), nreals)
end

SimulationProblem(geotable::GT, domain::D, var::VarOrVarType, nreals::Int) where {GT,D} =
  SimulationProblem(geotable, domain, (var,), nreals)

SimulationProblem(domain::D, varstypes::NTuple{N,VarType}, nreals::Int) where {D,N} =
  SimulationProblem{Nothing,D}(nothing, domain, NamedTuple(varstypes), nreals)

SimulationProblem(domain::D, var::VarType, nreals::Int) where {D} = SimulationProblem(domain, (var,), nreals)

"""
    data(problem)

Return the spatial data of the simulation `problem`.
"""
data(problem::SimulationProblem) = problem.geotable

"""
    domain(problem)

Return the spatial domain of the simulation `problem`.
"""
domain(problem::SimulationProblem) = problem.domain

"""
    variables(problem)

Return the target variables of the simulation `problem` and their types.
"""
variables(problem::SimulationProblem) = problem.vars

"""
    nreals(problem)

Return the number of realizations of the simulation `problem`.
"""
nreals(problem::SimulationProblem) = problem.nreals

# ------------
# IO methods
# ------------
function Base.show(io::IO, problem::SimulationProblem)
  Dim = embeddim(problem.domain)
  kind = isnothing(problem.geotable) ? "unconditional" : "conditional"
  print(io, "$(Dim)D SimulationProblem ($kind)")
end

function Base.show(io::IO, ::MIME"text/plain", problem::SimulationProblem)
  pvars = problem.vars
  vars = ["$var ($V)" for (var, V) in pairs(pvars)]
  println(io, problem)
  println(io, "  domain:    ", problem.domain)
  if !isnothing(problem.geotable)
    println(io, "  samples:   ", domain(problem.geotable))
  end
  println(io, "  targets:   ", join(vars, ", ", " and "))
  print(io, "  N° reals:  ", problem.nreals)
end
