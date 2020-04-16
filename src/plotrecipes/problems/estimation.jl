# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

@recipe function f(problem::EstimationProblem)
  pdata   = data(problem)
  pdomain = domain(problem)
  vars    = join(keys(variables(pdata)), ", ")

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
