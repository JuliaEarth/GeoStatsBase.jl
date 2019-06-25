# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

"""
    SimulationProblem(spatialdata, domain, targetvars, nreals)
    SimulationProblem(domain, targetvars, nreals)

A spatial simulation problem on a given `domain` in which the
variables to be simulated are listed in `targetvars`.

For conditional simulation, the data of the problem is stored in
`spatialdata`.

For unconditional simulation, a dictionary `targetvars` must be
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
julia> SimulationProblem(domain, Dict(:porosity => Float64, :facies => Int), 100)
```

### Notes

To check if a simulation problem has data (i.e. conditional vs.
unconditional) use the [`hasdata`](@ref) method.
"""
struct SimulationProblem{S<:Union{AbstractSpatialData,Nothing},
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
                                    mapper) where {S<:Union{AbstractSpatialData,Nothing},
                                                   D<:AbstractDomain,M<:AbstractMapper}
    probvnames = Tuple(keys(targetvars))

    @assert !isempty(probvnames) "target variables must be specified"
    @assert nreals > 0 "number of realizations must be positive"

    if spatialdata ≠ nothing
      mappings = map(spatialdata, domain, probvnames, mapper)
    else
      mappings = Dict(var => Dict() for var in probvnames)
    end

    new(spatialdata, domain, mapper, targetvars, nreals, mappings)
  end
end

function SimulationProblem(spatialdata::S, domain::D, targetvarnames::NTuple{N,Symbol}, nreals::Int;
                           mapper::M=SimpleMapper()) where {S<:AbstractSpatialData,
                                                            D<:AbstractDomain,
                                                            M<:AbstractMapper,
                                                            N}
  datavnames = Tuple(keys(variables(spatialdata)))
  datacnames = coordnames(spatialdata)

  @assert targetvarnames ⊆ datavnames "target variables must be present in spatial data"
  @assert isempty(targetvarnames ∩ datacnames) "target variables can't be coordinates"
  @assert ndims(domain) == length(datacnames) "data and domain must have the same number of dimensions"
  @assert coordtype(spatialdata) == coordtype(domain) "data and domain must have the same coordinate type"

  # build dictionary of target variables
  datavars = variables(spatialdata)
  targetvars = Dict(var => Base.nonmissingtype(T) for (var,T) in datavars if var ∈ targetvarnames)

  SimulationProblem{S,D,M}(spatialdata, domain, targetvars, nreals, mapper)
end

function SimulationProblem(spatialdata::S, domain::D, targetvarname::Symbol, nreals::Int;
                           mapper::M=SimpleMapper()) where {S<:AbstractSpatialData,
                                                            D<:AbstractDomain,
                                                            M<:AbstractMapper}
  SimulationProblem(spatialdata, domain, (targetvarname,), nreals; mapper=mapper)
end

function SimulationProblem(domain::D, targetvars::Dict{Symbol,DataType}, nreals::Int;
                           mapper::M=SimpleMapper()) where {D<:AbstractDomain,M<:AbstractMapper}
  SimulationProblem{Nothing,D,M}(nothing, domain, targetvars, nreals, mapper)
end

function SimulationProblem(domain::D, targetvar::Pair{Symbol,DataType}, nreals::Int;
                           mapper::M=SimpleMapper()) where {D<:AbstractDomain,M<:AbstractMapper}
  SimulationProblem(domain, Dict(targetvar), nreals; mapper=mapper)
end

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
