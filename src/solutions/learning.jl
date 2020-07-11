# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    LearningSolution

A solution to a spatial learning problem.
"""
struct LearningSolution{T,N,𝒟,𝒯} <: AbstractData{T,N}
  domain::𝒟
  table::𝒯
end

function LearningSolution(domain, table)
  T = coordtype(domain)
  N = ndims(domain)
  𝒟 = typeof(domain)
  𝒯 = typeof(table)
  LearningSolution{T,N,𝒟,𝒯}(domain, table)
end

# ------------
# IO methods
# ------------
function Base.show(io::IO, solution::LearningSolution)
  dim = ndims(solution.domain)
  print(io, "$(dim)D LearningSolution")
end

function Base.show(io::IO, ::MIME"text/plain", solution::LearningSolution)
  println(io, solution)
  println(io, "  domain: ", solution.domain)
  print(  io, "  variables: ", join(keys(variables(solution)), ", ", " and "))
end
