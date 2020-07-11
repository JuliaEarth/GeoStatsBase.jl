# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

# implement methods for spatial statistics
import Statistics: mean, var, quantile

"""
    SpatialStatistic

A spatial statistic defined over a spatial domain.
"""
struct SpatialStatistic{T,N,𝒟,𝒯} <: AbstractData{T,N}
  domain::𝒟
  table::𝒯
end

function SpatialStatistic(domain, table)
  T = coordtype(domain)
  N = ndims(domain)
  𝒟 = typeof(domain)
  𝒯 = typeof(table)
  SpatialStatistic{T,N,𝒟,𝒯}(domain, table)
end

# ------------
# IO methods
# ------------
function Base.show(io::IO, statistic::SpatialStatistic)
  N = ndims(domain(statistic))
  print(io, "$(N)D SpatialStatistic")
end

function Base.show(io::IO, ::MIME"text/plain", statistic::SpatialStatistic)
  println(io, statistic)
  println(io, "  domain: ", domain(statistic))
  print(  io, "  variables: ", join(keys(variables(statistic)), ", ", " and "))
end

include("statistics/data.jl")
include("statistics/solutions.jl")
