using GeoStatsBase
using DelimitedFiles
using Distances
using Distributions
using DataFrames
using Plots, VisualRegressionTests
using Test, Pkg, Random

# workaround GR warnings
ENV["GKSwstype"] = "100"

# environment settings
islinux = Sys.islinux()
istravis = "TRAVIS" ∈ keys(ENV)
datadir = joinpath(@__DIR__,"data")
visualtests = !istravis || (istravis && islinux)
if !istravis
  Pkg.add("Gtk")
  using Gtk
end

# dummy variables for testing
include("dummy.jl")

# list of tests
testfiles = [
  "distances.jl",
  "distributions.jl",
  "data.jl",
  "domains.jl",
  "collections.jl",
  "partitioning.jl",
  "paths.jl",
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
