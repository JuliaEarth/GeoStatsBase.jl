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
include("mappers.jl")
include("problems.jl")
include("solutions.jl")
include("solvers.jl")
include("comparisons.jl")
include("macros.jl")

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
  domain,
  digest,

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
