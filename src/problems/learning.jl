# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    LearningProblem(sdata, tdata, task)

A geostatistical learning problem with source data `sdata`,
target data `tdata`, and learning `task`.

## References

* Hoffimann et al. 2021. [Geostatistical Learning: Challenges and Opportunities]
  (https://www.frontiersin.org/articles/10.3389/fams.2021.689393/full)
"""
struct LearningProblem{Dₛ,Dₜ,T} <: Problem
  sdata::Dₛ
  tdata::Dₜ
  task::T

  function LearningProblem{Dₛ,Dₜ,T}(sdata, tdata, task) where {Dₛ,Dₜ,T}
    svars = Tables.schema(sdata).names
    tvars = Tables.schema(tdata).names

    # assert task is compatible with the data
    @assert features(task) ⊆ svars "features must be present in source data"
    @assert features(task) ⊆ tvars "features must be present in target data"
    if issupervised(task)
      @assert label(task) ∈ svars "label must be present in source data"
    end

    new(sdata, tdata, task)
  end
end

LearningProblem(sdata::Dₛ, tdata::Dₜ, task::T) where {Dₛ,Dₜ,T} = LearningProblem{Dₛ,Dₜ,T}(sdata, tdata, task)

"""
    sourcedata(problem)

Return the source data of the learning `problem`.
"""
sourcedata(problem::LearningProblem) = problem.sdata

"""
    targetdata(problem)

Return the target data of the learning `problem`.
"""
targetdata(problem::LearningProblem) = problem.tdata

"""
    task(problem)

Return the learning task of the learning `problem`.
"""
task(problem::LearningProblem) = problem.task

# ------------
# IO methods
# ------------
function Base.show(io::IO, problem::LearningProblem)
  Dim = embeddim(domain(problem.sdata))
  print(io, "$(Dim)D LearningProblem")
end

function Base.show(io::IO, ::MIME"text/plain", problem::LearningProblem)
  println(io, problem)
  println(io, "  source: ", domain(problem.sdata))
  println(io, "  target: ", domain(problem.tdata))
  print(io, "  task:   ", problem.task)
end
