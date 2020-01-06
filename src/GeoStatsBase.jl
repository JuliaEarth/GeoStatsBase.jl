# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

module GeoStatsBase

using Optim
using CSV: read
using Random: randperm, shuffle
using StatsBase: Histogram, AbstractWeights
using Distributions: median, mode
using Distributed: pmap, nworkers
using Distances: Metric, Euclidean, Mahalanobis, pairwise
using LinearAlgebra: Diagonal, normalize, norm, ⋅
using Distributions: ContinuousUnivariateDistribution
using DataFrames: AbstractDataFrame, eltypes, nrow
using NearestNeighbors: KDTree, knn, inrange
using StaticArrays: SVector, MVector
using AverageShiftedHistograms: ash
using SpecialFunctions: gamma
using DensityRatioEstimation
using RecipesBase
using Parameters

import Tables
import MLJBase
import StatsBase: fit, sample, varcorrection
import Distances: evaluate
import Distributions: quantile, cdf
import DataFrames: groupby

include("spatialobject.jl")
include("domains.jl")
include("domainview.jl")
include("data.jl")
include("dataview.jl")
include("collections.jl")
include("macros.jl")
include("paths.jl")
include("regions.jl")
include("distances.jl")
include("neighborhoods.jl")
include("neighborsearch.jl")
include("distributions.jl")
include("estimators.jl")
include("partitioning.jl")
include("weighting.jl")
include("covering.jl")
include("discretizing.jl")
include("sampling.jl")
include("joining.jl")
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
  georef,

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

  # learning tasks
  AbstractLearningTask,
  SupervisedLearningTask,
  UnsupervisedLearningTask,
  RegressionTask,
  ClassificationTask,
  ClusteringTask,
  CompositeTask,
  issupervised,
  iscomposite,
  inputvars,
  outputvars,
  features,
  label,

  # learning models
  issupervised,
  isprobabilistic,
  learn, perform,

  # learning examples
  AbstractLearningExample,
  AbstractLabeledExample,
  AbstractUnlabeledExample,
  LabeledPointExample,
  UnlabeledPointExample,

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
  BallSampleValidation,
  WeightedLossValidation,

  # helper macros
  @estimsolver,
  @simsolver,

  # paths
  AbstractPath,
  LinearPath,
  RandomPath,
  SourcePath,
  ShiftedPath,

  # regions
  AbstractRegion,
  RectangleRegion,
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
  coordtype,
  isneighbor,
  volume,
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

  # distributions
  EmpiricalDistribution,
  transform!, quantile, cdf,

  # estimators
  fit, predict, status,

  # partitioning
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
  SpatialWeights,
  AbstractWeighter,
  BlockWeighter,
  DensityRatioWeighter,
  weight,

  # covering
  AbstractCoverer,
  RectangleCoverer,
  cover,

  # discretizing
  AbstractDiscretizer,
  RegularGridDiscretizer,
  discretize,

  # sampling
  AbstractSampler,
  UniformSampler,
  BallSampler,
  sample,

  # joining
  AbstractJoiner,
  VariableJoiner,

  # statistics
  SpatialStatistic,
  EmpiricalHistogram,
  mean, var,
  quantile,

  # plot recipes
  cornerplot,

  # utilities
  readgeotable,
  groupby,
  boundbox

end
