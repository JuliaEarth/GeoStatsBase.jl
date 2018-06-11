using GeoStatsBase
using Test

# list of maintainers
maintainers = ["juliohm"]

# environment settings
istravis = "TRAVIS" ∈ keys(ENV)
ismaintainer = "USER" ∈ keys(ENV) && ENV["USER"] ∈ maintainers

# list of tests
testfiles = [
]

# run
for testfile in testfiles
  include(testfile)
end
