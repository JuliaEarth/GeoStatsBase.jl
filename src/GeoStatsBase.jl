## Copyright (c) 2017, Júlio Hoffimann Mendes <juliohm@stanford.edu>
##
## Permission to use, copy, modify, and/or distribute this software for any
## purpose with or without fee is hereby granted, provided that the above
## copyright notice and this permission notice appear in all copies.
##
## THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
## WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
## MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
## ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
## WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
## ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
## OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

__precompile__()

module GeoStatsBase

include("spatialdata.jl")
include("domains.jl")
include("mappers.jl")
include("problems.jl")
include("solutions.jl")
include("solvers.jl")

export
  # spatial data
  AbstractSpatialData,
  coordinates,
  coordtype,
  variables,
  valuetype,
  npoints,
  value,
  valid,

  # domains
  AbstractDomain,
  coordtype,
  npoints,
  coordinates,
  nearestlocation,

  # mappers
  AbstractMapper,
  SimpleMapper,

  # problems
  AbstractProblem,
  EstimationProblem,
  SimulationProblem,
  data,
  domain,
  variables,
  coordinates,
  datamap,
  hasdata,
  nreals,

  # solutions
  AbstractSolution,
  EstimationSolution,
  SimulationSolution,
  domain,
  digest,

  # solvers
  AbstractSolver,
  AbstractEstimationSolver,
  AbstractSimulationSolver,
  solve, solve_single

end
