# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

module GeoStatsBase

using CSV
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

# core concepts
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
include("neighsearch.jl")
include("distributions.jl")
include("partitions.jl")
include("weighting.jl")
include("statistics.jl")

# plot recipes
include("plotrecipes.jl")

# utilities
include("utils.jl")

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

  # neighborhood search
  AbstractNeighborSearcher,
  NearestNeighborSearcher,
  LocalNeighborSearcher,
  search!,

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
  weight,

  # statistics
  SpatialStatistic,
  mean, var,
  quantile,

  # utilities
  readgeotable

end
