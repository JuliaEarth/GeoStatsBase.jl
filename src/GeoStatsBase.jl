# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

module GeoStatsBase

using CSV
using Meshes
using Tables
using Combinatorics: multiexponents
using Distributed: CachingPool, pmap, myid
using LinearAlgebra: normalize, norm
using Distances: Euclidean, evaluate, pairwise
using StatsBase: Histogram, AbstractWeights, midpoints, sample
using Distributions: ContinuousUnivariateDistribution, median, mode
using CategoricalArrays: CategoricalValue, CategoricalArray
using CategoricalArrays: levels, isordered, pool
using StaticArrays: SVector, MVector
using AverageShiftedHistograms: ash
using Transducers: Map, foldxt
using DensityRatioEstimation
using ScientificTypes
using LossFunctions
using RecipesBase
using Parameters

using TypedTables # for a default table type
using Optim # for LSIF estimation

import Meshes
import MLJModelInterface
import Distributions: cdf
import StatsBase: fit, varcorrection
import Statistics: mean, var, quantile
import ScientificTypes: Scitype, scitype

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
