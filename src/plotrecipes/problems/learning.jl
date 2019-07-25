# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

@recipe function f(problem::LearningProblem)
  ptask   = task(problem)
  sdata   = sourcedata(problem)
  tdata   = targetdata(problem)
  svars   = join(keys(variables(sdata)), ", ")
  tvars   = join(keys(variables(tdata)), ", ")

  title --> string(ptask)
  legend --> true

  @series begin
    label --> "source data ($svars)"
    color --> :green
    marker --> :xcross
    domain(sdata)
  end
  @series begin
    label --> "target data ($tvars)"
    color --> :blue
    marker --> :xcross
    domain(tdata)
  end
end
