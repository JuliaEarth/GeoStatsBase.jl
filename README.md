# GeoStatsBase.jl

[![Build Status](https://travis-ci.org/juliohm/GeoStatsBase.jl.svg?branch=master)](https://travis-ci.org/juliohm/GeoStatsBase.jl)

This package contains problem and solution specifications for the
[GeoStats.jl](https://github.com/juliohm/GeoStats.jl) framework.
It is not intended to be used as a standalone package, and only
exists to make it possible for researchers to write their own
solvers independently of the main project.

## Geostatistical problems

### Estimation

An estimation problem in GeoStats.jl is constructed with the `EstimationProblem` type.
Objects of this type store the spatial data, the geometry of the domain, and the target
variables to be estimated.

A solution to an estimation problem is constructed with the `EstimationSolution` type.
Objects of this type store the geometry of the domain, the mean estimate, and the
variance (optional), for each variable of the problem.

### Simulation

A simulation problem in GeoStats.jl is constructed with the `SimulationProblem` type.
Objects of this type store the spatial data (optional), the geometry of the domain, and
the target variables to be estimated.

A solution to a simulation problem is constructed with the `SimulationProblem` type.
Objects of this type store the geometry of the domain, and the realizations, for each
variable of the problem.
