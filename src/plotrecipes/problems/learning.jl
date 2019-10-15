# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

@recipe function f(problem::LearningProblem)
  sdata   = sourcedata(problem)
  tdata   = targetdata(problem)
  svars   = join(sort([var for (var,V) in variables(sdata)]), ", ")
  tvars   = join(sort([var for (var,V) in variables(tdata)]), ", ")

  title --> "Learning Problem"
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
