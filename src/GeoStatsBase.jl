# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

module GeoStatsBase

using Meshes
using Tables
using Unitful
using GeoTables
using DataScienceTraits
using CategoricalArrays
using Rotations: RotZYX
using Distributions: median
using Distances: Euclidean, pairwise
using Distributed: CachingPool, pmap, myid
using StatsBase: Histogram, AbstractWeights
using StatsBase: midpoints, sample, mode
using DensityRatioEstimation
using ProgressMeter
using LinearAlgebra
using Random

using Unitful: AbstractQuantity, AffineUnits, Units
using ColumnSelectors: ColumnSelector, Column
using ColumnSelectors: AllSelector, NoneSelector
using ColumnSelectors: selector
using TableTransforms: Rename
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
include("hsactter.jl")

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
  UniqueCoords,

  # plotting
  hscatter,
  hscatter!

end
