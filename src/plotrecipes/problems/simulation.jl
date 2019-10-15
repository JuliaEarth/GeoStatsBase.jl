# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

@recipe function f(problem::SimulationProblem)
  pdata   = data(problem)
  pdomain = domain(problem)
  vars    = join(keys(variables(pdata)), ", ")

  title --> "Simulation Problem"
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
