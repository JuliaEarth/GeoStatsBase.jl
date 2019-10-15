# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    LeaveBallOut(ball)

Leave-`ball`-out (a.k.a. spatial leave-one-out) validation.

    LeaveBallOut(radius)

By default, use Euclidean ball of given `radius`.

## References

* Le Rest et al. 2014. Spatial leave-one-out
  cross-validation for variable selection in
  the presence of spatial autocorrelation.
"""
struct LeaveBallOut{B<:BallNeighborhood} <: AbstractErrorEstimator
  ball::B
end

LeaveBallOut(radius::Real) = LeaveBallOut(BallNeighborhood(radius))

function Base.error(solver::AbstractLearningSolver,
                    problem::LearningProblem,
                    eestimator::LeaveBallOut)
  sdata = sourcedata(problem)
  ovars = outputvars(task(problem))
  ball  = eestimator.ball

  # efficient neighborhood search
  searcher = NeighborhoodSearcher(sdata, ball)

  # pre-allocate memory for coordinates
  coords = MVector{ndims(sdata),coordtype(sdata)}(undef)

  solutions = pmap(1:npoints(sdata)) do i
    coordinates!(coords, sdata, i)

    # points inside and outside ball
    inside  = search(coords, searcher)
    outside = [j for j in 1:npoints(sdata) if j ∉ inside]

    # setup and solve learning sub-problem
    subproblem = LearningProblem(view(sdata, outside),
                                 view(sdata, [i]),
                                 task(problem))
    solve(subproblem, solver)
  end

  result = pmap(ovars) do var
    𝔏 = defaultloss(sdata[1,var])
    ŷ = [solutions[i][1,var] for i in 1:npoints(sdata)]
    y = [sdata[i,var] for i in 1:npoints(sdata)]
    var => 𝔏(ŷ, y)
  end

  Dict(result)
end
