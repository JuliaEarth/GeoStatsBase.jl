# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

@recipe function f(problem::LearningProblem)
  sdata = sourcedata(problem)
  tdata = targetdata(problem)
  svars = join(name.(variables(sdata)), ", ")
  tvars = join(name.(variables(tdata)), ", ")

  title --> "Learning Problem"
  legend --> true

  @series begin
    seriescolor --> :green
    label --> "source data ($svars)"
    marker --> :xcross
    domain(sdata)
  end
  @series begin
    seriescolor --> :blue
    label --> "target data ($tvars)"
    marker --> :xcross
    domain(tdata)
  end
end
