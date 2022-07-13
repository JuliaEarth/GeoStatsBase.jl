# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

module GeoStatsBase

using Meshes
using Tables
using TableTransforms
using LinearAlgebra: normalize
using Combinatorics: multiexponents
using Distributions: median, mode
using Distributed: CachingPool, pmap, myid
using Distances: Euclidean, evaluate, pairwise
using StatsBase: Histogram, AbstractWeights, midpoints, sample
using Transducers: Map, foldxt
using StaticArrays: SVector
using DensityRatioEstimation
using ScientificTypes
using LossFunctions
using RecipesBase
using Parameters
using ReferenceFrameRotations

using TypedTables # for a default table type
using Optim # for LSIF estimation

import Meshes
import MLJModelInterface
import StatsBase: fit, varcorrection
import Statistics: mean, var, quantile
import Base: ==

# aliases
const MI = MLJModelInterface
const GeoData = Meshes.MeshData

include("georef.jl")
include("ensembles.jl")
include("macros.jl")
include("trends.jl")
include("estimators.jl")
include("distributionals.jl")
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
include("rotations.jl")
include("plotrecipes.jl")

export
  # data
  GeoData,
  georef,

  # ensembles
  Ensemble,
  domain,

  # mapping
  MappingMethod,
  NearestMapping,
  CopyMapping,

  # learning tasks
  LearningTask,
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
  iscompatible,

  # learning losses
  defaultloss,

  # problems
  Problem,
  EstimationProblem,
  SimulationProblem,
  LearningProblem,
  data, domain,
  sourcedata,
  targetdata,
  task,
  variables,
  coordinates,
  hasdata,
  nreals,

  # solvers
  Solver,
  EstimationSolver,
  SimulationSolver,
  LearningSolver,
  targets,
  covariables,
  preprocess,
  solve, solvesingle,

  # folding
  FoldingMethod,
  UniformFolding,
  OneFolding,
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

  # estimators
  Estimator,
  fit,
  predict,
  status,

  # distributionals
  Distributional,

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

  # utilities
  uniquecoords,
  integrate,
  groupby,

  # rotations
  DatamineAngles,
  GslibAngles,
  VulcanAngles

end
