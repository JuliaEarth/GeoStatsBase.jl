using GeoStatsBase
using Meshes
using GeoTables
using CSV
using CoDa
using Tables
using Unitful
using TypedTables
using Distances
using Statistics
using Distributions
using LinearAlgebra
using TableTransforms
using CategoricalArrays
using DensityRatioEstimation
using Test, Random
using ImageIO
using FileIO: load
using MLJ: @load

import ScientificTypes as ST

# environment settings
datadir = joinpath(@__DIR__, "data")

# dummy definitions for testing
include("dummy.jl")

# list of tests
testfiles = [
  "ensembles.jl",
  "weighting.jl",
  "geoops.jl",
  "learning.jl",
  "problems.jl",
  "solvers.jl",
  "initbuff.jl",
  "folding.jl",
  "errors.jl",
  "statistics.jl",
  "histograms.jl",
  "rotations.jl",
  "macros.jl"
]

@testset "GeoStatsBase.jl" begin
  for testfile in testfiles
    println("Testing $testfile...")
    include(testfile)
  end
end
