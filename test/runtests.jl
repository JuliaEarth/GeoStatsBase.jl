using GeoStatsBase
using Meshes
using CSV
using CoDa
using Tables
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
  "georef.jl",
  "variables.jl",
  "ensembles.jl",
  "weighting.jl",
  "geoops.jl",
  "trends.jl",
  "learning.jl",
  "mappings.jl",
  "problems.jl",
  "solvers.jl",
  "folding.jl",
  "errors.jl",
  "statistics.jl",
  "histograms.jl",
  "rotations.jl",
  "macros.jl",
  "transforms.jl",
  "ui.jl"
]

@testset "GeoStatsBase.jl" begin
  for testfile in testfiles
    println("Testing $testfile...")
    include(testfile)
  end
end
