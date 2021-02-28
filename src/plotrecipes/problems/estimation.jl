# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

@recipe function f(problem::EstimationProblem)
  pdomain = domain(problem)
  pdata   = data(problem)
  vars    = join(name.(variables(pdata)), ", ")

  title --> "Estimation Problem"
  legend --> true

  @series begin
    label --> "domain"
    pdomain
  end
  @series begin
    seriescolor --> :blue
    label --> "data ($vars)"
    marker --> :xcross
    domain(pdata)
  end
end
