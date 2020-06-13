using GeoStatsBase
using DelimitedFiles
using Distances
using Distributions
using DataFrames
using DensityRatioEstimation
using LinearAlgebra
using Plots, VisualRegressionTests
using Test, Pkg, Random

# workaround GR warnings
ENV["GKSwstype"] = "100"

# environment settings
islinux = Sys.islinux()
istravis = "TRAVIS" ∈ keys(ENV)
isappveyor = "APPVEYOR" ∈ keys(ENV)
isCI = istravis || isappveyor
# Only run visual tests on Travis Linux
visualtests = !isCI || (istravis && islinux)
if !isCI
  Pkg.add("Gtk")
  using Gtk
end
datadir = joinpath(@__DIR__,"data")

# dummy variables for testing
include("dummy.jl")

# list of tests
testfiles = [
  "graphs.jl",
  "distances.jl",
  "distributions.jl",
  "data.jl",
  "domains.jl",
  "collections.jl",
  "partitioning.jl",
  "weighting.jl",
  "covering.jl",
  "filtering.jl",
  "paths.jl",
  "trends.jl",
  "regions.jl",
  "neighborhoods.jl",
  "mappers.jl",
  "problems.jl",
  "solvers.jl",
  "solutions.jl",
  "utils.jl",
  "statistics.jl",
  "learning.jl",
  "plotrecipes.jl"
]

@testset "GeoStatsBase.jl" begin
  for testfile in testfiles
    include(testfile)
  end
end
