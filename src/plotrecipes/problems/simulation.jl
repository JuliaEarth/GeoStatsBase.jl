# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

@recipe function f(problem::SimulationProblem)
  pdata   = data(problem)
  pdomain = domain(problem)
  vars    = join(name.(variables(pdata)), ", ")

  title --> "Simulation Problem"
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
