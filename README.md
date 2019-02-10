# GeoStatsBase.jl

[![][travis-img]][travis-url]

This package contains problem and solution specifications for the
[GeoStats.jl](https://github.com/juliohm/GeoStats.jl) framework.
It is not intended to be used as a standalone package, and only
exists to make it possible for researchers to write their own
solvers independently of the main project, and its development cycle.
A quick overview of the problems defined in the package is provided,
as well as short instructions on how to write solvers.

For additional developer tools, please check
[GeoStatsDevTools.jl](https://github.com/juliohm/GeoStatsDevTools.jl).

## Contents

- [Geostatistical problems](#geostatistical-problems)
  - [Estimation](#estimationproblem)
  - [Simulation](#simulationproblem)
- [Writing your own solver](#writing-your-own-solver)
- [Asking for help](#asking-for-help)

### Geostatistical problems

#### EstimationProblem

Objects of this type store the spatial data, the geometry of the domain, and the target
variables to be estimated.

```julia
struct EstimationProblem{S<:AbstractSpatialData,D<:AbstractDomain} <: AbstractProblem
  spatialdata::S
  domain::D
  targetvars::Dict{Symbol,DataType}
end
```

A solution to an estimation problem is constructed with the `EstimationSolution` type.
Objects of this type store the geometry of the domain, the mean estimate, and the
variance, for each variable of the problem.

```julia
struct EstimationSolution{D<:AbstractDomain} <: AbstractSolution
  domain::D
  mean::Dict{Symbol,Vector}
  variance::Dict{Symbol,Vector}
end
```

#### SimulationProblem

Objects of this type store the spatial data (optional), the geometry of the domain,
the target variables to be estimated, and the number of realizations. The function
`hasdata` can be used to check if the given simulation problem is conditional or
unconditional.

```julia
struct SimulationProblem{S<:Union{AbstractSpatialData,Nothing},D<:AbstractDomain} <: AbstractProblem
  spatialdata::S
  domain::D
  targetvars::Dict{Symbol,DataType}
  nreals::Int
end
```

A solution to a simulation problem is constructed with the `SimulationSolution` type.
Objects of this type store the geometry of the domain, and the realizations, for each
variable of the problem.

```julia
struct SimulationSolution{D<:AbstractDomain} <: AbstractSolution
  domain::D
  realizations::Dict{Symbol,Vector{Vector}}
end
```

### Writing your own solver

The task of writing a solver for a problem reduces to writing a simple function in Julia
that takes the problem as input and returns the solution. In this tutorial, I will write
an estimation solver that is not very useful (it fills the domain with random numbers),
but illustrates the development process.

#### Create the package

Install the `PkgTemplates.jl` package and create a new project:

```julia
using PkgTemplates

generate_interactive("MySolver")
```

This command will create a folder named `~/user/.julia/v0.x/MySolver` with all the files
that are necessary to start coding. You can check that the package is available by loading
it in the Julia prompt:

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
using GeoStatsBase
import GeoStatsBase: solve
```

These lines brings all the symbols defined in `GeoStatsBase` into scope, and tells Julia that
the method `solve` will be specialized for the new solver. Next, give your solver a name:

```julia
struct MyCoolSolver <: AbstractEstimationSolver
  # optional parameters go here
end
```

and export it so that it becomes available for users:

```julia
export MyCoolSolver
```

At this point, the `MySolver.jl` file should have the following content:

```julia
module MySolver

using GeoStatsBase
import GeoStatsBase: solve

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

geodata = readgeotable("somedata.csv", coordnames=[:x,:y])
domain  = RegularGrid{Float64}(100,100)
problem = EstimationProblem(geodata, grid, :value)

solution = solve(problem, MyCoolSolver())

plot(solution)
```

#### Simulation solvers

The process of writing a simulation solver is very similar, but there is an alternative function
to `solve` called `solve_single` that is *preferred*. The function `solve_single` takes a simulation
problem, one of the variables to be simulated, a solver, and a preprocessed input, and returns a
*vector* with the simulation results:

```julia
function solve_single(problem::SimulationProblem, var::Symbol, solver::MySimSolver, preproc)
  # retrieve problem info
  pdata = data(problem)
  pdomain = domain(problem)

  # output is a single realization
  realization = Vector(npoints(pdomain))

  # fill realization with hard data
  for (loc, datloc) in datamap(problem, var)
    realization[loc] = value(pdata, datloc, var)
  end

  # algorithm goes here
  # ...

  realization
end
```

This function is preferred over `solve` if your algorithm is the same for every single realization
(the algorithm is only a function of the random seed). In this case, GeoStats.jl will provide an
implementation of `solve` for you that calls `solve_single` in parallel.

The argument `preproc` is ignored unless the function `preprocess` is also defined for the solver.
The function takes a simulation problem and a solver, and returns an arbitrary object with
preprocessed data:

```julia
preprocess(problem::SimulationProblem, solver::MySimSolver) = nothing
```

### Asking for help

If you have any questions, please contact our community on the [gitter channel](https://gitter.im/JuliaEarth/GeoStats.jl).

[travis-img]: https://travis-ci.org/juliohm/GeoStatsBase.jl.svg?branch=master
[travis-url]: https://travis-ci.org/juliohm/GeoStatsBase.jl
