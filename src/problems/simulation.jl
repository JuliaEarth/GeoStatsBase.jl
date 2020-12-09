# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

const VarType      = Pair{Symbol,DataType}
const VarOrVarType = Union{Symbol,VarType}

"""
    SimulationProblem(sdata, sdomain, vars, nreals)
    SimulationProblem(sdomain, vars, nreals)

A spatial simulation problem on a given spatial domain `sdomain`
in which the variables to be simulated are listed in `vars`.

For conditional simulation, the data of the problem is stored in
spatial data `sdata`.

For unconditional simulation, a list of pairs `vars` must be
provided mapping variable names to their types.

In both cases, a number `nreals` of realizations is requested.

## Examples

Create a conditional simulation problem for porosity and permeability
with 100 realizations:

```julia
julia> SimulationProblem(sdata, sdomain, (:porosity,:permeability), 100)
```

Create an unconditional simulation problem for porosity and facies type
with 100 realizations:

```julia
julia> SimulationProblem(sdomain, (:porosity => Float64, :facies => Int), 100)
```
"""
struct SimulationProblem{S,D,N} <: AbstractProblem
  sdata::S
  sdomain::D
  vars::NTuple{N,Variable}
  nreals::Int

  function SimulationProblem{S,D,N}(sdata, sdomain, vars, nreals) where {S,D,N}
    pnames = name.(vars)

    @assert !isempty(pnames) "target variables must be specified"
    @assert nreals > 0 "number of realizations must be positive"

    new(sdata, sdomain, vars, nreals)
  end
end

function SimulationProblem(sdata::S, sdomain::D, vars::NTuple{N,VarOrVarType}, nreals::Int) where {S,D,N}
  @assert coordtype(sdata) == coordtype(sdomain) "data and domain must have the same coordinate type"

  datavars = Dict(name(var) => mactype(var) for var in variables(sdata))

  # pairs with variable names and types
  varstypes = map(vars) do vt
    if vt isa Symbol # for variables without type, find the type in spatial data
      var = vt
      if var ∈ keys(datavars)
        var => datavars[var]
      else
        @error "please specify the type of target variable $var"
      end
    else # for variables with type, make sure the type is valid
      var, T = vt
      if var ∈ keys(datavars)
        U = datavars[var]
        @assert U <: T "type $T for variable $var cannot hold values of type $U in spatial data"
      end
      vt
    end
  end

  vars = Tuple(Variable(var, V) for (var, V) in varstypes)

  SimulationProblem{S,D,N}(sdata, sdomain, vars, nreals)
end

SimulationProblem(sdata::S, sdomain::D, var::VarOrVarType, nreals::Int) where {S,D} =
  SimulationProblem(sdata, sdomain, (var,), nreals)

SimulationProblem(sdomain::D, vars::NTuple{N,VarType}, nreals::Int) where {D,N} =
  SimulationProblem{Nothing,D,N}(nothing, sdomain, Tuple(Variable(n, t) for (n, t) in vars), nreals)

SimulationProblem(sdomain::D, var::VarType, nreals::Int) where {D} =
  SimulationProblem(sdomain, (var,), nreals)

"""
    data(problem)

Return the spatial data of the simulation `problem`.
"""
data(problem::SimulationProblem) = problem.sdata

"""
    domain(problem)

Return the spatial domain of the simulation `problem`.
"""
domain(problem::SimulationProblem) = problem.sdomain

"""
    variables(problem)

Return the target variables of the simulation `problem` and their types.
"""
variables(problem::SimulationProblem) = problem.vars

"""
    hasdata(problem)

Return `true` if simulation `problem` has data.
"""
hasdata(problem::SimulationProblem) = !isnothing(problem.sdata)

"""
    nreals(problem)

Return the number of realizations of the simulation `problem`.
"""
nreals(problem::SimulationProblem) = problem.nreals

# ------------
# IO methods
# ------------
function Base.show(io::IO, problem::SimulationProblem)
  N = ncoords(problem.sdomain)
  kind = hasdata(problem) ? "conditional" : "unconditional"
  print(io, "$(N)D SimulationProblem ($kind)")
end

function Base.show(io::IO, ::MIME"text/plain", problem::SimulationProblem)
  vars = ["$(name(v)) ($(mactype(v)))" for v in problem.vars]
  println(io, problem)
  if problem.sdata ≠ nothing
    println(io, "  data:      ", problem.sdata)
  end
  println(io, "  domain:    ", problem.sdomain)
  println(io, "  variables: ", join(vars, ", ", " and "))
  print(  io, "  N° reals:  ", problem.nreals)
end
