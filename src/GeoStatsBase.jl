# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

module GeoStatsBase

using Random
using StatsBase
using Distances
using Distributions
using Distributed
using LinearAlgebra
using DataFrames
using NearestNeighbors
using StaticArrays
using Parameters
using RecipesBase

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

# developer tools
include("macros.jl")
include("paths.jl")
include("distances.jl")
include("neighborhoods.jl")
include("distributions.jl")
include("partitions.jl")
include("weighting.jl")

# plot recipes
include("plotrecipes.jl")

export
  # spatial object
  AbstractSpatialObject,
  domain,
  bounds,
  npoints,
  coordtype,
  coordnames,
  coordinates,
  coordinates!,
  nearestlocation,

  # domains
  AbstractDomain,
  PointSet,
  RegularGrid,
  StructuredGrid,
  origin,
  spacing,

  # spatial data
  AbstractSpatialData,
  GeoDataFrame,
  PointSetData,
  RegularGridData,
  StructuredGridData,
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

  ###################
  # DEVELOPER TOOLS #
  ###################

  # helper macros
  @estimsolver,
  @simsolver,

  # paths
  AbstractPath,
  SimplePath,
  RandomPath,
  SourcePath,
  ShiftedPath,

  # distances
  Ellipsoidal,
  evaluate,

  # neighborhoods
  AbstractNeighborhood,
  BallNeighborhood,
  CylinderNeighborhood,
  isneighbor,

  # distributions
  EmpiricalDistribution,
  transform!,
  quantile,
  cdf,

  # partitions
  SpatialPartition,
  AbstractPartitioner,
  AbstractFunctionPartitioner,
  AbstractSpatialFunctionPartitioner,
  UniformPartitioner,
  FractionPartitioner,
  BlockPartitioner,
  BallPartitioner,
  PlanePartitioner,
  DirectionPartitioner,
  FunctionPartitioner,
  ProductPartitioner,
  HierarchicalPartitioner,
  partition,
  subsets,
  →,

  # weighting
  WeightedSpatialData,
  AbstractWeighter,
  BlockWeighter,
  weight

end
