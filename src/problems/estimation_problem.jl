# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

"""
    EstimationProblem(spatialdata, domain, targetvars)

A spatial estimation problem on a given `domain` in which the
variables to be estimated are listed in `targetvars`. The
data of the problem is stored in `spatialdata`.

## Examples

Create an estimation problem for rainfall precipitation measurements:

```julia
julia> EstimationProblem(spatialdata, domain, :precipitation)
```

Create an estimation problem for precipitation and CO₂:

```julia
julia> EstimationProblem(spatialdata, domain, (:precipitation,:CO₂))
```
"""
struct EstimationProblem{S<:AbstractData,
                         D<:AbstractDomain,
                         M<:AbstractMapper} <: AbstractProblem
  # input fields
  spatialdata::S
  domain::D
  mapper::M
  targetvars::Dict{Symbol,DataType}

  # state fields
  mappings::Dict{Symbol,Dict{Int,Int}}

  function EstimationProblem{S,D,M}(spatialdata, domain, targetvars,
                                    mapper) where {S<:AbstractData,
                                                   D<:AbstractDomain,
                                                   M<:AbstractMapper}
    probvnames = Tuple(keys(targetvars))
    datavnames = Tuple(keys(variables(spatialdata)))
    datacnames = coordnames(spatialdata)

    @assert !isempty(probvnames) && probvnames ⊆ datavnames "target variables must be present in spatial data"
    @assert isempty(probvnames ∩ datacnames) "target variables can't be coordinates"
    @assert ndims(domain) == length(datacnames) "data and domain must have the same number of dimensions"
    @assert coordtype(spatialdata) == coordtype(domain) "data and domain must have the same coordinate type"

    mappings = map(spatialdata, domain, probvnames, mapper)

    new(spatialdata, domain, mapper, targetvars, mappings)
  end
end

function EstimationProblem(spatialdata::S, domain::D, targetvarnames::NTuple{N,Symbol};
                           mapper::M=SimpleMapper()) where {S<:AbstractData,
                                                            D<:AbstractDomain,
                                                            M<:AbstractMapper,
                                                            N}
  # build dictionary of target variables
  datavars = variables(spatialdata)
  targetvars = Dict(var => Base.nonmissingtype(T) for (var,T) in datavars if var ∈ targetvarnames)

  EstimationProblem{S,D,M}(spatialdata, domain, targetvars, mapper)
end

function EstimationProblem(spatialdata::S, domain::D, targetvarname::Symbol;
                           mapper::M=SimpleMapper()) where {S<:AbstractData,
                                                            D<:AbstractDomain,
                                                            M<:AbstractMapper}
  EstimationProblem(spatialdata, domain, (targetvarname,); mapper=mapper)
end

"""
    data(problem)

Return the spatial data of the estimation `problem`.
"""
data(problem::EstimationProblem) = problem.spatialdata

"""
    domain(problem)

Return the spatial domain of the estimation `problem`.
"""
domain(problem::EstimationProblem) = problem.domain

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
  dim = ndims(problem.domain)
  print(io, "$(dim)D EstimationProblem")
end

function Base.show(io::IO, ::MIME"text/plain", problem::EstimationProblem)
  vars = ["$var ($T)" for (var,T) in problem.targetvars]
  println(io, problem)
  println(io, "  data:      ", problem.spatialdata)
  println(io, "  domain:    ", problem.domain)
  print(  io, "  variables: ", join(vars, ", ", " and "))
end
