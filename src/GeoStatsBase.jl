# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

module GeoStatsBase

using Meshes
using Tables
using GeoTables
using StaticArrays
using DataScienceTraits
using CategoricalArrays
using Rotations: RotZYX, Rotation
using Distances: Euclidean, pairwise
using StatsBase: Histogram, AbstractWeights
using StatsBase: midpoints, sample, median
using DensityRatioEstimation
using LinearAlgebra

using ColumnSelectors: ColumnSelector, AllSelector, selector
using DataScienceTraits: Categorical

using TypedTables # for a default table type
using Optim # for LSIF estimation

import GeoTables: domain
import StatsBase: fit, varcorrection, describe
import Statistics: mean, var, quantile
import Base: ==

include("ensembles.jl")
include("weighting.jl")
include("geoops.jl")
include("initbuff.jl")
include("folding.jl")
include("statistics.jl")
include("histograms.jl")
include("rotations.jl")
include("hscatter.jl")

export
  # ensembles
  Ensemble,

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

  # weighting
  GeoWeights,
  WeightingMethod,
  UniformWeighting,
  BlockWeighting,
  DensityRatioWeighting,
  weight,

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

  # plotting
  hscatter,
  hscatter!

end
