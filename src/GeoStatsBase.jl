# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

module GeoStatsBase

using Meshes
using MeshIntegrals
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

function __init__()
  # register error hint for visualization functions
  # since this is a recurring issue for new users
  Base.Experimental.register_error_hint(MethodError) do io, exc, argtypes, kwargs
    if exc.f == hscatter || exc.f == hscatter!
      if isnothing(Base.get_extension(GeoStatsBase, :GeoStatsBaseMakieExt))
        print(
          io,
          """

          Did you import a Makie.jl backend (e.g., GLMakie.jl, CairoMakie.jl) for visualization?

          """
        )
        printstyled(
          io,
          """
          julia> using GeoStatsBase
          julia> import GLMakie # or CairoMakie, WGLMakie, etc.
          """,
          color=:cyan,
          bold=true
        )
      end
    end
  end
end

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
