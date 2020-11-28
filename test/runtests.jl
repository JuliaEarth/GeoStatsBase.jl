using GeoStatsBase
using DelimitedFiles
using Distances
using Distributions
using Tables, DataFrames
using DensityRatioEstimation
using CategoricalArrays
using LinearAlgebra
using Plots, VisualRegressionTests
using Test, Pkg, Random

using MLJ: @load

# workaround GR warnings
ENV["GKSwstype"] = "100"

# environment settings
islinux = Sys.islinux()
istravis = "TRAVIS" ∈ keys(ENV)
isappveyor = "APPVEYOR" ∈ keys(ENV)
isCI = istravis || isappveyor
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
  "distances.jl",
  "distributions.jl",
  "data.jl",
  "domains.jl",
  "views.jl",
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
  "mappers.jl",
  "problems.jl",
  "solvers.jl",
  "solutions.jl",
  "folding.jl",
  "errors.jl",
  "statistics.jl",
  "plotrecipes.jl",
  "utils.jl",
  "macros.jl"
]

@testset "GeoStatsBase.jl" begin
  for testfile in testfiles
    include(testfile)
  end
end
