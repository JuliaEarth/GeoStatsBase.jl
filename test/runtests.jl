using GeoStatsBase
using Distances
using Distributions
using Tables, DataFrames
using DensityRatioEstimation
using CategoricalArrays
using LinearAlgebra
using DelimitedFiles
using Test, Random, Plots
using ReferenceTests, PNGFiles

# load some learning models from MLJ
using MLJ: @load
dtree = @load DecisionTreeClassifier verbosity=0

# workaround GR warnings
ENV["GKSwstype"] = "100"

# environment settings
isCI = "CI" ∈ keys(ENV)
islinux = Sys.islinux()
visualtests = !isCI || (isCI && islinux)
datadir = joinpath(@__DIR__,"data")

# helper function for visual regression tests
function asimage(plt)
  io = IOBuffer()
  show(io, "image/png", plt)
  seekstart(io)
  PNGFiles.load(io)
end

# dummy variables for testing
include("dummy.jl")

# list of tests
testfiles = [
  "distances.jl",
  "distributions.jl",
  "data.jl",
  "domains.jl",
  "views.jl",
  "ensembles.jl",
  "georef.jl",
  "partitioning.jl",
  "weighting.jl",
  "sampling.jl",
  "geoops.jl",
  "paths.jl",
  "trends.jl",
  "geometries.jl",
  "neighborhoods.jl",
  "neighborsearch.jl",
  "learning.jl",
  "mappings.jl",
  "problems.jl",
  "solvers.jl",
  "folding.jl",
  "errors.jl",
  "statistics.jl",
  "plotrecipes.jl",
  "utils.jl",
  "macros.jl"
]

@testset "GeoStatsBase.jl" begin
  for testfile in testfiles
    @info "Processing $testfile..."
    include(testfile)
  end
end
