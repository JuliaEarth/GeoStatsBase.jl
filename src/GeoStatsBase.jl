# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

module GeoStatsBase

using Meshes
using Tables
using Unitful
using GeoTables
using Rotations
using StaticArrays
using DataScienceTraits
using CategoricalArrays
using Rotations: rot_eltype
using Distances: Euclidean, pairwise
using StatsBase: Histogram, AbstractWeights
using StatsBase: midpoints, sample, median
using DensityRatioEstimation
using LinearAlgebra

using ColumnSelectors: ColumnSelector, AllSelector, selector

using TypedTables # for a default table type
using Optim # for LSIF estimation

import StatsBase: fit, varcorrection, describe
import StatsBase: mean, var, quantile

# main source files
include("weighting.jl")
include("geoops.jl")
include("folding.jl")
include("statistics.jl")
include("histograms.jl")
include("rotations.jl")

# plot recipes
include("hscatter.jl")

export
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
  MinesightAngles,

  # plot recipes
  hscatter,
  hscatter!

end
