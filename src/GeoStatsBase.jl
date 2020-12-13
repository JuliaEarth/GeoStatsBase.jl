# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

module GeoStatsBase

using CSV
using Optim
using Random: randperm, shuffle
using Combinatorics: multiexponents
using Distributed: CachingPool, pmap, myid
using LinearAlgebra: Diagonal, normalize, norm, ⋅
using StatsBase: Histogram, Weights, AbstractWeights
using Distances: Metric, Euclidean, Mahalanobis, pairwise
using Distributions: ContinuousUnivariateDistribution, median, mode
using CategoricalArrays: CategoricalValue, CategoricalArray
using CategoricalArrays: levels, isordered, pool, levelcode
using NearestNeighbors: KDTree, BallTree, knn, inrange
using ReferenceFrameRotations: angle_to_dcm
using DataFrames: DataFrame, DataFrame!
using StaticArrays: SVector, MVector, SOneTo
using AverageShiftedHistograms: ash
using Transducers: Map, foldxt
using SpecialFunctions: gamma
using DensityRatioEstimation
using ScientificTypes
using LossFunctions
using RecipesBase
using Parameters

import Tables
import MLJModelInterface
import Base: values, ==
import Base: in, filter, map, split, error
import StatsBase: fit, sample, varcorrection
import Statistics: mean, var, quantile
import Distributions: quantile, cdf
import ScientificTypes: Scitype, scitype
import Distances: evaluate
import DataFrames: groupby
import NearestNeighbors: MinkowskiMetric

# aliases
const MI = MLJModelInterface
const Vec{N,T} = Union{SVector{N,T},MVector{N,T}}

# convention of scientific types
include("convention.jl")

function __init__()
  ScientificTypes.set_convention(GeoStats())
end

include("variables.jl")
include("geotraits.jl")
include("domains.jl")
include("domainview.jl")
include("data.jl")
include("dataview.jl")
include("georef.jl")
include("macros.jl")
include("paths.jl")
include("trends.jl")
include("geometries.jl")
include("distances.jl")
include("neighborhoods.jl")
include("neighborsearch.jl")
include("distributions.jl")
include("estimators.jl")
include("partitioning.jl")
include("weighting.jl")
include("discretizing.jl")
include("sampling.jl")
include("geoops.jl")
include("learning.jl")
include("mappings.jl")
include("problems.jl")
include("solvers.jl")
include("solutions.jl")
include("folding.jl")
include("errors.jl")
include("statistics.jl")
include("plotrecipes.jl")
include("utils.jl")

export
  # spatial variable
  Variable,
  name, mactype,

  # geotraits
  nelms,
  ncoords,
  coordtype,
  coordinates,
  coordinates!,
  domain,
  values,

  # spatial domains
  AbstractDomain,
  PointSet,
  RegularGrid,
  StructuredGrid,
  origin, spacing,

  # spatial data
  AbstractData,
  SpatialData,
  variables,
  georef,

  # mapping
  MappingMethod,
  NearestMapping,
  CopyMapping,

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
  variables,
  coordinates,
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

  # folding
  FoldingMethod,
  RandomFolding,
  PointFolding,
  BlockFolding,
  BallFolding,
  folds,

  # errors
  ErrorEstimationMethod,
  LeaveOneOut,
  LeaveBallOut,
  CrossValidation,
  BlockCrossValidation,
  WeightedCrossValidation,
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

  # geometries
  AbstractGeometry,
  Rectangle,
  sides,
  center,
  diagonal,
  volume,

  # distances
  aniso2distance,
  evaluate,

  # neighborhoods
  AbstractNeighborhood,
  BallNeighborhood,
  isneighbor,
  radius,
  metric,

  # neighborhood search
  NeighborSearchMethod,
  BoundedNeighborSearchMethod,
  KNearestSearch,
  NeighborhoodSearch,
  BoundedSearch,
  KBallSearch,
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
  PartitionMethod,
  PredicatePartitionMethod,
  SPredicatePartitionMethod,
  RandomPartition,
  FractionPartition,
  SLICPartition,
  BlockPartition,
  BisectPointPartition,
  BisectFractionPartition,
  BallPartition,
  PlanePartition,
  DirectionPartition,
  PredicatePartition,
  SPredicatePartition,
  VariablePartition,
  ProductPartition,
  HierarchicalPartition,
  partition,
  subsets,
  metadata,
  →,

  # weighting
  SpatialWeights,
  WeightingMethod,
  UniformWeighting,
  BlockWeighting,
  DensityRatioWeighting,
  weight,

  # discretizing
  DiscretizationMethod,
  BlockDiscretization,
  discretize,

  # sampling
  SamplingMethod,
  UniformSampling,
  WeightedSampling,
  BallSampling,
  sample,

  # operations
  uniquecoords,
  inside,

  # trends
  polymat,
  trend,

  # statistics
  EmpiricalHistogram,
  mean, var, quantile,

  # plot recipes
  cornerplot,

  # utilities
  readgeotable,
  groupby,
  boundbox,
  slice,
  spheredir

end
