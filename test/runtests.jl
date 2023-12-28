using GeoStatsBase
using Meshes
using GeoTables
using CSV
using CoDa
using Tables
using Unitful
using TypedTables
using Rotations
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

# environment settings
datadir = joinpath(@__DIR__, "data")

# list of tests
testfiles = [
  "ensembles.jl",
  "weighting.jl",
  "geoops.jl",
  "initbuff.jl",
  "folding.jl",
  "statistics.jl",
  "histograms.jl",
  "rotations.jl"
]

@testset "GeoStatsBase.jl" begin
  for testfile in testfiles
    println("Testing $testfile...")
    include(testfile)
  end
end
