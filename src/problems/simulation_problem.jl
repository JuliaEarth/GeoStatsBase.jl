# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    SimulationProblem(spatialdata, domain, targetvars, nreals)
    SimulationProblem(domain, targetvars, nreals)

A spatial simulation problem on a given `domain` in which the
variables to be simulated are listed in `targetvars`.

For conditional simulation, the data of the problem is stored in
`spatialdata`.

For unconditional simulation, a list of pairs `targetvars` must be
provided mapping variable names to their types.

In both cases, a number `nreals` of realizations is requested.

## Examples

Create a conditional simulation problem for porosity and permeability
with 100 realizations:

```julia
julia> SimulationProblem(spatialdata, domain, (:porosity,:permeability), 100)
```

Create an unconditional simulation problem for porosity and facies type
with 100 realizations:

```julia
julia> SimulationProblem(domain, (:porosity => Float64, :facies => Int), 100)
```

### Notes

To check if a simulation problem has data (i.e. conditional vs.
unconditional) use the [`hasdata`](@ref) method.
"""
struct SimulationProblem{S<:Union{AbstractData,Nothing},
                         D<:AbstractDomain,M<:AbstractMapper} <: AbstractProblem
  # input fields
  spatialdata::S
  domain::D
  mapper::M
  targetvars::Dict{Symbol,DataType}
  nreals::Int

  # state fields
  mappings::Dict{Symbol,Dict{Int,Int}}

  function SimulationProblem{S,D,M}(spatialdata, domain, targetvars, nreals,
                                    mapper) where {S<:Union{AbstractData,Nothing},
                                                   D<:AbstractDomain,M<:AbstractMapper}
    probvnames = Tuple(keys(targetvars))

    @assert !isempty(probvnames) "target variables must be specified"
    @assert nreals > 0 "number of realizations must be positive"

    if spatialdata ≠ nothing
      datavnames = Tuple(keys(variables(spatialdata)))
      dmappings = map(spatialdata, domain, datavnames, mapper)
      omappings = Dict(var => Dict() for var in probvnames if var ∉ datavnames)
      mappings  = merge(dmappings, omappings)
    else
      mappings = Dict(var => Dict() for var in probvnames)
    end

    new(spatialdata, domain, mapper, targetvars, nreals, mappings)
  end
end

const VarType      = Pair{Symbol,DataType}
const VarOrVarType = Union{Symbol,VarType}

function SimulationProblem(spatialdata::S, domain::D, vars::NTuple{N,VarOrVarType}, nreals::Int;
                           mapper::M=NearestMapper()) where {S<:AbstractData,D<:AbstractDomain,M<:AbstractMapper,N}
  datavars = Dict(var => Base.nonmissingtype(V) for (var,V) in variables(spatialdata))

  # for variables without type, find the type in spatial data
  targetvars₁ = map(Iterators.filter(v -> v isa Symbol, vars)) do var
    if var ∈ keys(datavars)
      var => datavars[var]
    else
      @error "please specify the type of target variable $var"
    end
  end

  # for variables with type, make sure the type is valid
  targetvars₂ = map(Iterators.filter(v -> v isa Pair, vars)) do pair
    var, T = pair
    if var ∈ keys(datavars)
      U = datavars[var]
      @assert U <: T "type $T for variable $var cannot hold values of type $U in spatial data"
    end
    pair
  end

  targetvars = merge(Dict(targetvars₁), Dict(targetvars₂))

  @assert ndims(spatialdata) == ndims(domain) "data and domain must have the same number of dimensions"
  @assert coordtype(spatialdata) == coordtype(domain) "data and domain must have the same coordinate type"
  @assert isempty(keys(targetvars) ∩ coordnames(domain)) "target variables can't be coordinates"

  SimulationProblem{S,D,M}(spatialdata, domain, targetvars, nreals, mapper)
end

SimulationProblem(spatialdata::S, domain::D, var::VarOrVarType, nreals::Int;
                  mapper::M=NearestMapper()) where {S<:AbstractData,D<:AbstractDomain,M<:AbstractMapper} =
  SimulationProblem(spatialdata, domain, (var,), nreals; mapper=mapper)

SimulationProblem(domain::D, vars::NTuple{N,VarType}, nreals::Int;
                  mapper::M=NearestMapper()) where {D<:AbstractDomain,M<:AbstractMapper,N} =
  SimulationProblem{Nothing,D,M}(nothing, domain, Dict(vars), nreals, mapper)

SimulationProblem(domain::D, var::VarType, nreals::Int;
                  mapper::M=NearestMapper()) where {D<:AbstractDomain,M<:AbstractMapper} =
  SimulationProblem(domain, (var,), nreals; mapper=mapper)

"""
    data(problem)

Return the spatial data of the simulation `problem`.
"""
data(problem::SimulationProblem) = problem.spatialdata

"""
    domain(problem)

Return the spatial domain of the simulation `problem`.
"""
domain(problem::SimulationProblem) = problem.domain

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
datamap(problem::SimulationProblem, var::Symbol) = problem.mappings[var]

"""
    datamap(problem)

Return the mappings from domain locations to data locations for all
the variables of the `problem`.
"""
datamap(problem::SimulationProblem) = problem.mappings

"""
    hasdata(problem)

Return `true` if simulation `problem` has data.
"""
hasdata(problem::SimulationProblem) = (problem.spatialdata ≠ nothing &&
                                       npoints(problem.spatialdata) > 0)

"""
    nreals(problem)

Return the number of realizations of the simulation `problem`.
"""
nreals(problem::SimulationProblem) = problem.nreals

# ------------
# IO methods
# ------------
function Base.show(io::IO, problem::SimulationProblem)
  dim = ndims(problem.domain)
  kind = hasdata(problem) ? "conditional" : "unconditional"
  print(io, "$(dim)D SimulationProblem ($kind)")
end

function Base.show(io::IO, ::MIME"text/plain", problem::SimulationProblem)
  vars = ["$var ($T)" for (var,T) in problem.targetvars]
  println(io, problem)
  if problem.spatialdata ≠ nothing
    println(io, "  data:      ", problem.spatialdata)
  end
  println(io, "  domain:    ", problem.domain)
  println(io, "  variables: ", join(vars, ", ", " and "))
  print(  io, "  N° reals:  ", problem.nreals)
end
