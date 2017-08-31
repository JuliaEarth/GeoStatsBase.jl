# GeoStatsBase.jl

[![Build Status](https://travis-ci.org/juliohm/GeoStatsBase.jl.svg?branch=master)](https://travis-ci.org/juliohm/GeoStatsBase.jl)

This package contains problem and solution specifications for the
[GeoStats.jl](https://github.com/juliohm/GeoStats.jl) framework.
It is not intended to be used as a standalone package, and only
exists to make it possible for researchers to write their own
solvers independently of the main project. Below we give an
overview of the types defined in the package, and short
instructions on how you can write your own solver.

## Contents

- [Geostatistical problems](#geostatistical-problems)
  - [Estimation](#estimation)
  - [Simulation](#simulation)
- [Writing your own solver](#writing-your-own-solver)
- [Asking for help](#asking-for-help)

### Geostatistical problems

#### Estimation

An estimation problem in GeoStats.jl is constructed with the `EstimationProblem` type.
Objects of this type store the spatial data, the geometry of the domain, and the target
variables to be estimated.

A solution to an estimation problem is constructed with the `EstimationSolution` type.
Objects of this type store the geometry of the domain, the mean estimate, and the
variance, for each variable of the problem.

#### Simulation

A simulation problem in GeoStats.jl is constructed with the `SimulationProblem` type.
Objects of this type store the spatial data (optional), the geometry of the domain, and
the target variables to be estimated. The function `hasdata` can be used to check if
the given `SimulationProblem` is conditional or unconditional.

A solution to a simulation problem is constructed with the `SimulationSolution` type.
Objects of this type store the geometry of the domain, and the realizations, for each
variable of the problem.

### Writing your own solver

The task of writing a solver for a problem reduces to writing a simple function in Julia
that takes the problem as input and returns the solution. In this tutorial, I will write
an estimation solver that is not very useful, but illustrates the development process.

#### Create the package

Install the `PkgDev.jl` package and create a new project:

```julia
using PkgDev

PkgDev.generate("MySolver","ISC") # create a package with the ISC license
```

This command will create a folder `~/user/.julia/v0.x/MySolver` with all the files that
are necessary to start coding. You can check that the package is available by loading it
in the Julia prompt:

```julia
using MySolver
```

Choose your favorite open source license for your solver. If you don't have a favorite, I
suggest using the `ISC` license. This license is equivalent to the `MIT` and `BSD 2-Clause`
licenses, plus it eliminates [unncessary language](https://en.wikipedia.org/wiki/ISC_license).
All these licenses are permissive meaning that the software that uses it can be incorported
into commercial products.

#### Import GeoStatsBase

After the package is created, open the main source file `MySolver.jl` and add the following
line:

```julia
importall GeoStatsBase
```

This line brings all the symbols defined in `GeoStatsBase` into scope. Next, give your solver
a name:

```julia
struct MyCoolSolver <: AbstractEstimationSolver
  # optional parameters go here
end
```

and export it so that it becomes available for users:

```julia
export MyCoolSolver
```

At this point, the `MySolver.jl` should have the following content:

```julia
module MySolver

importall GeoStatsBase

export MyCoolSolver

struct MyCoolSolver <: AbstractEstimationSolver
  # optional parameters go here
end

end # module
```

#### Write the algorithm

Now that your solver type is defined, write your algorithm. Write a function called `solve`
that takes an estimation problem and your solver, and returns an estimation solution:

```julia
function solve(problem::EstimationProblem, solver::MyCoolSolver)
  pdomain = domain(problem)

  mean = Dict{Symbol,Vector}()
  variance = Dict{Symbol,Vector}()
  
  for (var,V) in variables(problem)
    push!(mean, var => rand(npoints(pdomain)))
    push!(variance, var => rand(npoints(pdomain)))
  end

  EstimationSolution(pdomain, mean, variance)
end
```

Paste this function somewhere in your package, and you are all set.

#### Test the solver

To test your new solver, load the `GeoStats.jl` package and solve a simple problem:

```julia
using GeoStats
using MySolver

geodata = readtable("somedata.csv", coordnames=[:x,:y])
grid = RegularGrid{Float64}(100,100)
problem = EstimationProblem(geodata, grid, :value)

solution = solve(problem, MyCoolSolver())

plot(solution)
```

#### Simulation solvers

The process of writing a simulation solver is very similar, but there is an alternative function
to `solve` called `solve_single` that is *preferred*. The function `solve_single` takes a simulation
problem, one of the variables to be simulated, and a solver, and returns a *vector* with the simulation
results:

```julia
function solve_single(problem::SimulationProblem, var::Symbol, solver::MySimSolver)
  # algorithm goes here
  # ...
  
  # return a single realization for the variable
  Vector(npoints(domain(problem)))
end
```

This function is preferred over `solve` if your algorithm is the same for every single realization
(the algorithm is only a function of the random seed). In this case, GeoStats.jl will provide an
implementation of `solve` for you that calls `solve_single` in parallel.

### Asking for help

If you have any questions, please [open an issue](https://github.com/juliohm/GeoStatsBase.jl/issues)
without thinking twice. I will be happy to help.
