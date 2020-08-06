# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

module GeoStatsBase

using CSV
using Optim
using Distributed: pmap
using Random: randperm, shuffle
using Combinatorics: multiexponents
using LinearAlgebra: Diagonal, normalize, norm, ⋅
using StatsBase: Histogram, Weights, AbstractWeights
using Distances: Metric, Euclidean, Mahalanobis, pairwise
using Distributions: ContinuousUnivariateDistribution, median, mode
using CategoricalArrays: CategoricalValue, CategoricalArray
using CategoricalArrays: levels, isordered, pool
using NearestNeighbors: KDTree, knn, inrange
using DataFrames: DataFrame, DataFrame!
using StaticArrays: SVector, MVector
using AverageShiftedHistograms: ash
using SpecialFunctions: gamma
using DensityRatioEstimation
using ScientificTypes
using LossFunctions
using RecipesBase
using Parameters

import Tables
import MLJModelInterface
import Base: join, filter, map, split, error
import StatsBase: fit, sample, varcorrection
import Statistics: mean, var, quantile
import Distributions: quantile, cdf
import ScientificTypes: Scitype, scitype
import Distances: evaluate
import DataFrames: groupby

const MI = MLJModelInterface

# convention of scientific types
include("convention.jl")

function __init__()
  ScientificTypes.set_convention(GeoStats())
end

# basic graph utils
include("graphs.jl")

include("variables.jl")
include("spatialobject.jl")
include("domains.jl")
include("domainview.jl")
include("data.jl")
include("dataview.jl")
include("georef.jl")
include("setops.jl")
include("macros.jl")
include("paths.jl")
include("trends.jl")
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
include("filtering.jl")
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
  SpatialData,
  variables,
  georef,
  valid,

  # set operations
  ⊔,

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
  issupervised,
  inputvars,
  outputvars,
  features,
  label,

  # learning models
  issupervised,
  isprobabilistic,
  learn, perform,

  # learning losses
  defaultloss,

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

  # solvers
  AbstractSolver,
  AbstractEstimationSolver,
  AbstractSimulationSolver,
  AbstractLearningSolver,
  SeqSim,
  SeqSimParam,
  CookieCutter,
  CookieCutterParam,
  PointwiseLearn,
  variables,
  covariables,
  preprocess,
  solve, solvesingle,

  # errors
  AbstractErrorEstimator,
  LeaveBallOut,
  CrossValidation,
  BlockCrossValidation,
  WeightedHoldOut,
  WeightedCrossValidation,
  WeightedBootstrap,
  DensityRatioValidation,

  # helper macros
  @estimsolver,
  @simsolver,

  # paths
  AbstractPath,
  LinearPath,
  RandomPath,
  SourcePath,
  ShiftedPath,
  traverse,

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
  KBallSearcher,
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
  AbstractPredicatePartitioner,
  AbstractSpatialPredicatePartitioner,
  UniformPartitioner,
  FractionPartitioner,
  SLICPartitioner,
  BlockPartitioner,
  BisectPointPartitioner,
  BisectFractionPartitioner,
  BallPartitioner,
  PlanePartitioner,
  DirectionPartitioner,
  PredicatePartitioner,
  SpatialPredicatePartitioner,
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
  WeightedSampler,
  BallSampler,
  sample,

  # joining
  AbstractJoiner,
  VariableJoiner,

  # filtering
  AbstractFilter,
  UniqueCoordsFilter,

  # trends
  polymat,
  trend,
  detrend!,

  # statistics
  EmpiricalHistogram,
  mean, var, quantile,

  # plot recipes
  cornerplot,

  # utilities
  groupby,
  boundbox,
  readgeotable,
  uniquecoords,
  spheredir

end
