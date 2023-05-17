# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

module GeoStatsBase

using Meshes
using Tables
using TableTransforms
using Distributions: median
using Combinatorics: multiexponents
using Distances: Euclidean, pairwise
using Distributed: CachingPool, pmap, myid
using StatsBase: Histogram, AbstractWeights
using StatsBase: midpoints, sample, mode
using Transducers: Map, foldxt
using ReferenceFrameRotations
using DensityRatioEstimation
using ScientificTypes
using LossFunctions

using TypedTables # for a default table type
using Optim # for LSIF estimation

import Meshes
import MLJModelInterface as MI
import TableTransforms: StatelessTableTransform
import TableTransforms: StatelessFeatureTransform
import TableTransforms: ColSpec, NoneSpec, Col, colspec, choose
import TableTransforms: apply, revert, reapply
import TableTransforms: applyfeat, revertfeat
import TableTransforms: applymeta, revertmeta
import TableTransforms: divide, attach
import TableTransforms: isrevertible
import StatsBase: fit, varcorrection
import Statistics: mean, var, quantile
import Base: ==

# aliases
const GeoData = Meshes.MeshData

include("georef.jl")
include("variables.jl")
include("ensembles.jl")
include("macros.jl")
include("trends.jl")
include("estimators.jl")
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
include("transforms.jl")
include("ui.jl")

export
  # data
  GeoData,
  georef,

  # variables
  Variable,
  variables,
  mactype,
  name,

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
  solve,
  solvesingle,

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
  uniquecoords,
  integrate,
  @groupby,
  @transform,
  @combine,

  # rotations
  DatamineAngles,
  GslibAngles,
  VulcanAngles,

  # transforms
  Detrend,
  Potrace,
  UniqueCoords,

  # UI elements
  searcher_ui

end
