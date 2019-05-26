# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

module GeoStatsBase

using LinearAlgebra
using Distributed
using StaticArrays
using Parameters

include("spatialdata.jl")
include("spatialdataview.jl")
include("domains.jl")
include("domainview.jl")
include("mappers.jl")
include("problems.jl")
include("solutions.jl")
include("solvers.jl")
include("comparisons.jl")
include("macros.jl")

# sometimes spatial data and domain can be treated as equal
const AbstractDataOrDomain{T,N} = Union{AbstractSpatialData{T,N},
                                        AbstractDomain{T,N}}

# spatial objects have a domain
domain(object) = object.domain

export
  # spatial data
  AbstractSpatialData,
  coordtype,
  coordnames,
  coordinates,
  coordinates!,
  variables,
  valuetype,
  npoints,
  value,
  valid,

  # domains
  AbstractDomain,
  coordtype,
  coordinates,
  coordinates!,
  npoints,
  nearestlocation,

  # data or domain
  AbstractDataOrDomain,

  # mappers
  AbstractMapper,
  SimpleMapper,
  CopyMapper,

  # problems
  AbstractProblem,
  EstimationProblem,
  SimulationProblem,
  data,
  domain,
  mapper,
  variables,
  coordinates,
  datamap,
  hasdata,
  nreals,

  # solutions
  AbstractSolution,
  EstimationSolution,
  SimulationSolution,

  # solvers
  AbstractSolver,
  AbstractEstimationSolver,
  AbstractSimulationSolver,
  solve, solve_single,
  preprocess,

  # comparisons
  AbstractSolverComparison,
  AbstractEstimSolverComparison,
  AbstractSimSolverComparison,
  compare,

  # helper macros
  @estimsolver,
  @simsolver

end
