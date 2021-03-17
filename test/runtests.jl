using GeoStatsBase
using Meshes
using Distances
using Distributions
using Tables, TypedTables
using Test, Random, Plots
using ReferenceTests, ImageIO

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
  "distributions.jl",
  "ensembles.jl",
  "georef.jl",
  "weighting.jl",
  "geoops.jl",
  "trends.jl",
  "learning.jl",
  "mappings.jl",
  "problems.jl",
  "folding.jl",
  "errors.jl",
  "statistics.jl",
  "histograms.jl",
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
