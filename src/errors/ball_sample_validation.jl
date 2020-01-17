# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    BallSampleValidation(eestimator, sourceradius, targetradius;
                         metric=Euclidean(), tol=1e-4, maxiter=10)

Ball sample validation with error estimator `eestimator`, based on
samples collected from source and target data. `sourceradius` is
the radius of the ball for the source data and `targetradius` is
the radius of the ball for the target data.
"""
struct BallSampleValidation{E<:AbstractErrorEstimator,
                            Rₛ,Rₜ,M<:Metric} <: AbstractErrorEstimator
  eestimator::E
  sradius::Rₛ
  tradius::Rₜ
  metric::M
  tol::Float64
  maxiter::Int
end

BallSampleValidation(eestimator::AbstractErrorEstimator, sradius::Rₛ, tradius::Rₜ;
                     metric=Euclidean(), tol=1e-4, maxiter=10) where {Rₛ,Rₜ} =
  BallSampleValidation(eestimator, sradius, tradius, metric, tol, maxiter)

function Base.error(solver::AbstractLearningSolver,
                    problem::LearningProblem,
                    eestimator::BallSampleValidation)
  # source and target data
  sdata = sourcedata(problem)
  tdata = targetdata(problem)
  ovars = outputvars(task(problem))

  @assert ndims(sdata) == ndims(tdata) "source and target domain must have same dimension"

  # source and target samplers
  sradius = eestimator.sradius
  tradius = eestimator.tradius
  metric  = eestimator.metric
  ssampler = BallSampler(sradius, metric)
  tsampler = BallSampler(tradius, metric)

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
