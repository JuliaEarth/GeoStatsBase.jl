# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

module GeoStatsBase

using CSV: read
using Random: randperm, shuffle
using StatsBase: Histogram, sample, weights, midpoints
using Distributions: median, mode
using Distributed: pmap, nworkers
using Distances: Metric, Euclidean, Mahalanobis, pairwise
using LinearAlgebra: Diagonal, normalize, norm, ⋅
using Distributions: ContinuousUnivariateDistribution
using DataFrames: AbstractDataFrame, eltypes, nrow
using NearestNeighbors: KDTree, knn, inrange
using StaticArrays: SVector, MVector
using AverageShiftedHistograms: ash
using RecipesBase
using Parameters

import Tables
import MLJBase
import StatsBase: fit, sample
import Distances: evaluate
import Distributions: quantile, cdf

include("spatialobject.jl")
include("domains.jl")
include("domainview.jl")
include("data.jl")
include("dataview.jl")
include("collections.jl")
include("macros.jl")
include("paths.jl")
include("shapes.jl")
include("distances.jl")
include("neighborhoods.jl")
include("neighborsearch.jl")
include("distributions.jl")
include("estimators.jl")
include("partitioning.jl")
include("weighting.jl")
include("covering.jl")
include("sampling.jl")
include("learning.jl")
include("mappers.jl")
include("problems.jl")
include("solvers.jl")
include("solutions.jl")
include("errors.jl")
include("statistics.jl")
include("plotrecipes.jl")
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
  valid,

  # collections
  DomainCollection,
  DataCollection,

  # mappers
  AbstractMapper,
  NearestMapper,
  CopyMapper,

  # tasks
  AbstractLearningTask,
  SupervisedLearningTask,
  UnsupervisedLearningTask,
  RegressionTask,
  ClassificationTask,
  ClusteringTask,
  CompositeTask,
  features, label,
  issupervised,
  iscomposite,

  # models
  issupervised,
  isprobabilistic,

  # problems
  AbstractProblem,
  EstimationProblem,
  SimulationProblem,
  LearningProblem,
  data,
  domain,
  sourcedata,
  targetdata,
  task,
  mapper,
  variables,
  coordinates,
  datamap,
  hasdata,
  nreals,

  # solutions
  EstimationSolution,
  SimulationSolution,
  LearningSolution,

  # solvers
  AbstractSolver,
  AbstractEstimationSolver,
  AbstractSimulationSolver,
  SeqSim,
  SeqSimParam,
  CookieCutter,
  CookieCutterParam,
  PointwiseLearn,
  solve, solve_single,
  preprocess,

  # errors
  AbstractErrorEstimator,
  LeaveBallOut,
  CrossValidation,
  BlockCrossValidation,
  estimate_error,
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

  # shapes
  AbstractShape,
  Rectangle,
  center,
  lowerleft,
  upperright,
  side,
  sides,
  diagonal,
  volume,

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
  object,

  # learning example
  AbstractLearningExample,
  AbstractLabeledExample,
  AbstractUnlabeledExample,
  LabeledPointExample,
  UnlabeledPointExample,

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
  BisectPointPartitioner,
  BisectFractionPartitioner,
  BallPartitioner,
  PlanePartitioner,
  DirectionPartitioner,
  FunctionPartitioner,
  VariablePartitioner,
  ProductPartitioner,
  HierarchicalPartitioner,
  partition,
  subsets,
  metadata,
  →,

  # weighting
  WeightedSpatialData,
  AbstractWeighter,
  BlockWeighter,
  weight,

  # covering
  AbstractCoverer,
  RectangleCoverer,
  cover, boundbox,

  # sampling
  AbstractSampler,
  UniformSampler,
  BallSampler,
  sample,

  # statistics
  SpatialStatistic,
  mean, var,
  quantile,
  histogram,

  # plot recipes
  cornerplot,

  # utilities
  readgeotable

end
