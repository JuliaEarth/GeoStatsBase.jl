# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENCE in the project root.
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
    label --> "data ($vars)"
    color --> :blue
    marker --> :xcross
    domain(pdata)
  end
end
