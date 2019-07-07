# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

module GeoStatsBase

using CSV: read
using Random: randperm, shuffle
using StatsBase: sample, weights
using Distributed: pmap, nworkers
using Distances: Metric, Euclidean, Mahalanobis, pairwise
using LinearAlgebra: Diagonal, normalize, norm, ⋅
using Distributions: ContinuousUnivariateDistribution
using DataFrames: AbstractDataFrame, eltypes, nrow
using NearestNeighbors: KDTree, knn, inrange
using StaticArrays: SVector, MVector
using RecipesBase: @recipe, @series, plot, RecipesBase
using Parameters

import Distances: evaluate
import Distributions: quantile, cdf

# core concepts
include("spatialobject.jl")
include("domains.jl")
include("domainview.jl")
include("spatialdata.jl")
include("spatialdataview.jl")
include("collections.jl")
include("mappers.jl")
include("tasks.jl")
include("problems.jl")
include("solutions.jl")

# developer tools
include("macros.jl")
include("paths.jl")
include("distances.jl")
include("neighborhoods.jl")
include("neighborsearch.jl")
include("distributions.jl")
include("estimators.jl")
include("partitions.jl")
include("weighting.jl")
include("statistics.jl")

# solvers and comparisons
include("solvers.jl")
include("comparisons.jl")

# plot recipes
include("plotrecipes.jl")

# utilities
include("utils.jl")

export
  # spatial object
  AbstractSpatialObject,
  domain,
  bounds,
  boundvolume,
  npoints,
  coordtype,
  coordnames,
  coordinates,
  coordinates!,
  nearestlocation,

  # domains
  AbstractDomain,
  Curve,
  PointSet,
  RegularGrid,
  StructuredGrid,
  origin, spacing,

  # spatial data
  AbstractData,
  CurveData,
  GeoDataFrame,
  PointSetData,
  RegularGridData,
  StructuredGridData,
  variables,
  valuetype,
  value,
  valid,

  # collections
  DomainCollection,
  DataCollection,

  # mappers
  AbstractMapper,
  SimpleMapper,
  CopyMapper,

  # tasks
  AbstractLearningTask,
  SupervisedLearningTask,
  UnsupervisedLearningTask,
  RegressionTask,
  ClassificationTask,
  ClusteringTask,
  features, label,

  # problems
  AbstractProblem,
  EstimationProblem,
  SimulationProblem,
  LearningProblem,
  data,
  domain,
  sourcedata,
  targetdata,
  targetdomain,
  task,
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
  SeqSim, SeqSimParam,
  CookieCutter, CookieCutterParam,
  solve, solve_single,
  preprocess,

  # comparisons
  AbstractSolverComparison,
  AbstractEstimSolverComparison,
  AbstractSimSolverComparison,
  VisualComparison,
  CrossValidation,
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
  radius,
  height,
  metric,

  # neighborhood search
  AbstractNeighborSearcher,
  AbstractBoundedNeighborSearcher,
  NearestNeighborSearcher,
  NeighborhoodSearcher,
  BoundedSearcher,
  search!, search,
  maxneighbors,

  # distributions
  EmpiricalDistribution,
  transform!, quantile, cdf,

  # estimators
  fit, predict, status,

  # partitions
  SpatialPartition,
  AbstractPartitioner,
  AbstractFunctionPartitioner,
  AbstractSpatialFunctionPartitioner,
  UniformPartitioner,
  FractionPartitioner,
  SLICPartitioner,
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
