# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

"""
    VisualComparison([plot options])

Compare solvers by plotting the results side by side.

## Examples

```julia
julia> compare([solver₁, solver₂], problem, VisualComparison())
```
"""
struct VisualComparison <: AbstractSolverComparison
  plotspecs
end

VisualComparison(; plotspecs...) = VisualComparison(plotspecs)

function compare(solvers::AbstractVector{S}, problem::AbstractProblem,
                 cmp::VisualComparison) where {S<:AbstractSolver}

  # check if Plots.jl is loaded
  isdefined(Main, :Plots) || @error "please load Plots.jl for visual comparison"

  plts = pmap(solvers) do solver
    solution = solve(problem, solver)
    RecipesBase.plot(solution)
  end

  RecipesBase.plot(plts..., layout=(length(solvers),1))
end
