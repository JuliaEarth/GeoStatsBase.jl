# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

module GeoStatsBase

using Meshes
using Tables
using Unitful
using GeoTables
using DataScienceTraits
using Rotations: RotZYX
using Distributions: median
using Distances: Euclidean, pairwise
using Distributed: CachingPool, pmap, myid
using StatsBase: Histogram, AbstractWeights
using StatsBase: midpoints, sample, mode
using Transducers: Map, foldxt
using LossFunctions: L2DistLoss, MisclassLoss
using DensityRatioEstimation
using ProgressMeter
using LinearAlgebra
using Random

using Unitful: AbstractQuantity, AffineUnits, Units
using ColumnSelectors: ColumnSelector, Column
using ColumnSelectors: AllSelector, NoneSelector
using ColumnSelectors: selector
using TableTransforms: Rename
using DataScienceTraits: Continuous, Categorical

using TypedTables # for a default table type
using Optim # for LSIF estimation

import GeoTables: domain
import MLJModelInterface as MI
import LossFunctions.Traits: SupervisedLoss
import StatsBase: fit, varcorrection, describe
import Statistics: mean, var, quantile
import Base: ==

include("ensembles.jl")
include("macros.jl")
include("weighting.jl")
include("geoops.jl")
include("learning.jl")
include("problems.jl")
include("solvers.jl")
include("initbuff.jl")
include("folding.jl")
include("errors.jl")
include("statistics.jl")
include("histograms.jl")
include("rotations.jl")

export
  # ensembles
  Ensemble,

  # learning tasks
  LearningTask,
  SupervisedLearningTask,
  UnsupervisedLearningTask,
  RegressionTask,
  ClassificationTask,
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
  data,
  domain,
  sourcedata,
  targetdata,
  task,
  variables,
  nreals,

  # solvers
  Solver,
  EstimationSolver,
  SimulationSolver,
  LearningSolver,
  targets,
  covariables,
  preprocess,
  solve,
  solvesingle,

  # initialization
  InitMethod,
  NearestInit,
  ExplicitInit,
  initbuff,

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
  KFoldValidation,
  BlockValidation,
  WeightedValidation,
  DensityRatioValidation,

  # helper macros
  @estimsolver,
  @simsolver,

  # estimators
  Estimator,
  ProbabilisticEstimator,
  fit,
  predict,
  predictprob,
  status,

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
  mean,
  var,
  quantile,

  # utilities
  describe,
  integrate,
  geosplit,

  # rotations
  DatamineAngles,
  GslibAngles,
  VulcanAngles,

  # transforms
  Detrend,
  Potrace,
  Rasterize,
  UniqueCoords

end
