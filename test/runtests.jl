using GeoStatsBase
using Test

# list of tests
testfiles = [
]

# run
for testfile in testfiles
  include(testfile)
end
