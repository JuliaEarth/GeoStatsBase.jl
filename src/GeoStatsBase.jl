# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

module GeoStatsBase

using LinearAlgebra
using Distributed
using StaticArrays
using Parameters

include("spatialobject.jl")
include("domains.jl")
include("domainview.jl")
include("spatialdata.jl")
include("spatialdataview.jl")
include("mappers.jl")
include("problems.jl")
include("solutions.jl")
include("solvers.jl")
include("comparisons.jl")
include("macros.jl")

export
  # spatial object
  AbstractSpatialObject,
  domain,
  npoints,
  coordtype,
  coordnames,
  coordinates,
  coordinates!,
  coordextrema,
  nearestlocation,

  # domains
  AbstractDomain,

  # spatial data
  AbstractSpatialData,
  variables,
  valuetype,
  value,
  valid,

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
