# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    SimulationProblem(sdata, sdomain, targetvars, nreals)
    SimulationProblem(sdomain, targetvars, nreals)

A spatial simulation problem on a given spatial domain `sdomain`
in which the variables to be simulated are listed in `targetvars`.

For conditional simulation, the data of the problem is stored in
spatial data `sdata`.

For unconditional simulation, a list of pairs `targetvars` must be
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
struct SimulationProblem{S,D,M} <: AbstractProblem
  # input fields
  sdata::S
  sdomain::D
  mapper::M
  targetvars::Dict{Symbol,DataType}
  nreals::Int

  # state fields
  maps::Dict{Symbol,Dict{Int,Int}}

  function SimulationProblem{S,D,M}(sdata, sdomain, targetvars, nreals, mapper) where {S,D,M}
    pnames = Tuple(keys(targetvars))

    @assert !isempty(pnames) "target variables must be specified"
    @assert nreals > 0 "number of realizations must be positive"

    if isnothing(sdata)
      maps   = Dict(var => Dict() for var in pnames)
    else
      vnames = name.(variables(sdata))
      dmaps  = map(sdata, sdomain, vnames, mapper)
      omaps  = Dict(var => Dict() for var in pnames if var ∉ vnames)
      maps   = merge(dmaps, omaps)
    end

    new(sdata, sdomain, mapper, targetvars, nreals, maps)
  end
end

const VarType      = Pair{Symbol,DataType}
const VarOrVarType = Union{Symbol,VarType}

function SimulationProblem(sdata::S, sdomain::D, vars::NTuple{N,VarOrVarType}, nreals::Int;
                           mapper::M=NearestMapper()) where {S,D,M,N}
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

  targetvars = Dict(varstypes)

  @assert coordtype(sdata) == coordtype(sdomain) "data and domain must have the same coordinate type"

  SimulationProblem{S,D,M}(sdata, sdomain, targetvars, nreals, mapper)
end

SimulationProblem(sdata::S, sdomain::D, var::VarOrVarType, nreals::Int;
                  mapper::M=NearestMapper()) where {S,D,M} =
  SimulationProblem(sdata, sdomain, (var,), nreals; mapper=mapper)

SimulationProblem(sdomain::D, vars::NTuple{N,VarType}, nreals::Int;
                  mapper::M=NearestMapper()) where {D,M,N} =
  SimulationProblem{Nothing,D,M}(nothing, sdomain, Dict(vars), nreals, mapper)

SimulationProblem(sdomain::D, var::VarType, nreals::Int;
                  mapper::M=NearestMapper()) where {D,M} =
  SimulationProblem(sdomain, (var,), nreals; mapper=mapper)

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
    mapper(problem)

Return the mapper of the simulation `problem`.
"""
mapper(problem::SimulationProblem) = problem.mapper

"""
    variables(problem)

Return the target variables of the simulation `problem` and their types.
"""
variables(problem::SimulationProblem) = problem.targetvars

"""
    datamap(problem, targetvar)

Return the mapping from domain locations to data locations for the
`targetvar` of the `problem`.
"""
datamap(problem::SimulationProblem, var::Symbol) = problem.maps[var]

"""
    datamap(problem)

Return the mappings from domain locations to data locations for all
the variables of the `problem`.
"""
datamap(problem::SimulationProblem) = problem.maps

"""
    hasdata(problem)

Return `true` if simulation `problem` has data.
"""
hasdata(problem::SimulationProblem) = (problem.sdata ≠ nothing &&
                                       npoints(problem.sdata) > 0)

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
  vars = ["$var ($T)" for (var,T) in problem.targetvars]
  println(io, problem)
  if problem.sdata ≠ nothing
    println(io, "  data:      ", problem.sdata)
  end
  println(io, "  domain:    ", problem.sdomain)
  println(io, "  variables: ", join(vars, ", ", " and "))
  print(  io, "  N° reals:  ", problem.nreals)
end
