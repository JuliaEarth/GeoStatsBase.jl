using GeoStatsBase
using Meshes
using CSV
using CoDa
using Tables
using TypedTables
using Distances
using Distributions
using TableTransforms
using CategoricalArrays
using DensityRatioEstimation
using ReferenceFrameRotations
using Test, Random, Plots
using ReferenceTests, ImageIO

import ScientificTypes as ST

# workaround GR warnings
ENV["GKSwstype"] = "100"

# environment settings
isCI = "CI" ∈ keys(ENV)
islinux = Sys.islinux()
visualtests = !isCI || (isCI && islinux)
datadir = joinpath(@__DIR__,"data")

# dummy definitions for testing
include("dummy.jl")

# list of tests
testfiles = [
  "georef.jl",
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
    @info "Testing $testfile..."
    include(testfile)
  end
end
