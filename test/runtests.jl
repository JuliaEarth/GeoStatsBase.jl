using GeoStatsBase
using DelimitedFiles
using Distances: Euclidean, Chebyshev
using DataFrames: DataFrame
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

# list of tests
testfiles = [
  "distances.jl",
  "distributions.jl",
  "spatialdata.jl",
  "domains.jl",
  "partitions.jl",
  "paths.jl",
  "neighborhoods.jl",
  "mappers.jl",
  "problems.jl",
  "utils.jl",
  "statistics.jl"
]

@testset "GeoStatsBase.jl" begin
  for testfile in testfiles
    include(testfile)
  end
end
