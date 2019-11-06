# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    BallSampleValidation(eestimator, sourceball, targetball;
                         tol=1e-4, maxiter=10)

Ball sample validation with error estimator `eestimator`, based on
samples collected from source and target data. `sourceball` is the
ball for the source and `targetball` is the ball for the target.

    BallSampleValidation(eestimator, sourceradius, targetradius;
                         tol=1e-4, maxiter=10)

Alternatively, specify the radii for Euclidean balls.
"""
struct BallSampleValidation{E<:AbstractErrorEstimator,
                            Bₛ<:BallNeighborhood,
                            Bₜ<:BallNeighborhood} <: AbstractErrorEstimator
  eestimator::E
  sourceball::Bₛ
  targetball::Bₜ
  tol::Float64
  maxiter::Int
end

BallSampleValidation(eestimator::AbstractErrorEstimator,
                     sball::BallNeighborhood,
                     tball::BallNeighborhood;
                     tol=1e-4, maxiter=10) =
  BallSampleValidation(eestimator, sball, tball, tol, maxiter)

BallSampleValidation(eestimator::AbstractErrorEstimator,
                     sradius::Real, tradius::Real;
                     tol=1e-4, maxiter=10) =
  BallSampleValidation(eestimator,
                       BallNeighborhood(sradius),
                       BallNeighborhood(tradius);
                       tol=tol, maxiter=maxiter)

function Base.error(solver::AbstractLearningSolver,
                    problem::LearningProblem,
                    eestimator::BallSampleValidation)
  # source and target data
  sdata = sourcedata(problem)
  tdata = targetdata(problem)
  ovars = outputvars(task(problem))

  # source and target balls
  sball = eestimator.sourceball
  tball = eestimator.targetball

  # source and target samplers
  ssampler = BallSampler(sball)
  tsampler = BallSampler(tball)

  # helper function
  function iid_estimate(ssamples, tsamples)
    subproblem = LearningProblem(ssamples, tsamples, task(problem))
    error(solver, subproblem, eestimator.eestimator)
  end

  # initialization with i.i.d. samples
  res = iid_estimate(sample(sdata, ssampler), sample(tdata, tsampler))

  # iteration parameters
  tol     = eestimator.tol
  maxiter = eestimator.maxiter
  err     = Dict(var => Inf for var in ovars)
  iter    = 0
  while maximum(values(err)) > tol && iter < maxiter
    # copy old result
    old = copy(res)
    iter += 1

    # estimate with more i.i.d. samples
    new = iid_estimate(sample(sdata, ssampler), sample(tdata, tsampler))

    # update result (online mean formula)
    for var in ovars
      res[var] = (iter*old[var] + new[var])/(iter + 1)
      err[var] = abs(res[var] - old[var]) / old[var]
    end
  end

  res
end
