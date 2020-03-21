# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    GeoStats

`ScientificTypes.jl` convention adopted in the GeoStats.jl project.
"""
struct GeoStats <: Convention end

# Basic values
scitype(::Integer,        ::GeoStats) = Count
scitype(::AbstractFloat,  ::GeoStats) = Continuous
scitype(::AbstractString, ::GeoStats) = Textual

# Categorical values
function scitype(c::CategoricalValue, ::GeoStats)
  L = length(levels(c))
  ifelse(isordered(pool(c)), OrderedFactor{L}, Multiclass{L})
end
function scitype(A::CategoricalArray{T,N}, ::GeoStats) where {T,N}
  L = length(levels(A))
  S = ifelse(isordered(A), OrderedFactor{L}, Multiclass{L})
  T >: Missing && (S = Union{S,Missing})
  AbstractArray{S,N}
end

# Scitype for fast array broadcasting
Scitype(::Type{<:Integer},        ::GeoStats) = Count
Scitype(::Type{<:AbstractFloat},  ::GeoStats) = Continuous
Scitype(::Type{<:AbstractString}, ::GeoStats) = Textual
