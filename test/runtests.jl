using GeoStatsBase
using Base.Test

# list of maintainers
maintainers = ["juliohm"]

# environment settings
istravis = "TRAVIS" ∈ keys(ENV)
ismaintainer = "USER" ∈ keys(ENV) && ENV["USER"] ∈ maintainers
datadir = joinpath(@__DIR__,"data")

# load some data
fname = joinpath(datadir,"data2D.tsv")
data2D = readtable(fname, coordnames=[:x,:y])
fname = joinpath(datadir,"data3D.tsv")
data3D = readtable(fname)

# list of tests
testfiles = [
  "geodataframe.jl"
]

# run
for testfile in testfiles
  include(testfile)
end
