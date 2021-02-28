# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

module GeoStatsBase

using CSV
using Optim
using Meshes
using Tables
using Random: randperm, shuffle
using Combinatorics: multiexponents
using Distributed: CachingPool, pmap, myid
using LinearAlgebra: Diagonal, normalize, norm, ⋅
using StatsBase: Histogram, Weights, AbstractWeights, midpoints
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

import Meshes
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

# convention of scientific types
include("convention.jl")

function __init__()
  ScientificTypes.set_convention(GeoStats())
end

include("geodata.jl")
include("ensembles.jl")
include("georef.jl")
include("macros.jl")
include("trends.jl")
include("distributions.jl")
include("estimators.jl")
include("partitioning.jl")
include("weighting.jl")
include("geoops.jl")
include("learning.jl")
include("mappings.jl")
include("problems.jl")
include("solvers.jl")
include("folding.jl")
include("errors.jl")
include("statistics.jl")
include("histograms.jl")
include("plotrecipes.jl")
include("utils.jl")

export
  # geospatial data
  GeoData,
  georef,

  # spatial ensembles
  Ensemble,

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

  # distances
  aniso2distance,
  evaluate,

  # distributions
  EmpiricalDistribution,
  transform!, quantile, cdf,

  # estimators
  fit, predict, status,

  # partitioning
  SLIC,

  # weighting
  GeoWeights,
  WeightingMethod,
  UniformWeighting,
  BlockWeighting,
  DensityRatioWeighting,
  weight,

  # trends
  polymat,
  trend,

  # histograms
  EmpiricalHistogram,

  # statistics
  mean, var, quantile,

  # plot recipes
  cornerplot,

  # utilities
  readgeotable,
  uniquecoords,
  groupby,
  spheredir

end
