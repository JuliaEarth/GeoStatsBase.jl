# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

# implement methods for spatial statistics
import Statistics: mean, var, quantile

"""
    SpatialStatistic

A spatial statistic defined over a spatial domain.
"""
struct SpatialStatistic{T,N,D<:AbstractDomain{T,N}} <: AbstractData{T,N}
  data::Dict{Symbol,<:AbstractArray}
  domain::D
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
