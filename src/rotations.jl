# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

abstract type IndustryRotation{T} <: Rotation{3,T} end

function toangles end

function rotparams end

function (::Type{Rot})(t::NTuple{9}) where {Rot<:IndustryRotation}
  R = SMatrix{3,3}(t)

  θ₁ = atan(R[2, 1], R[1, 1])
  θ₂ = atan(-R[3, 1], (R[3, 2] * R[3, 2] + R[3, 3] * R[3, 3])^(1 / 2))
  sinθ₁, cosθ₁ = sincos(θ₁)
  θ₃ = atan(R[1, 3] * sinθ₁ - R[2, 3] * cosθ₁, R[2, 2] * cosθ₁ - R[1, 2] * sinθ₁)

  Rot(toangles(Rot, θ₁, θ₂, θ₃)...)
end

function Base.Tuple(r::IndustryRotation)
  θ₁, θ₂, θ₃ = rotparams(r)

  sinθ₁, cosθ₁ = sincos(θ₁)
  sinθ₂, cosθ₂ = sincos(θ₂)
  sinθ₃, cosθ₃ = sincos(θ₃)

  # transposed representation
  (
    cosθ₁ * cosθ₂,
    sinθ₁ * cosθ₂,
    -sinθ₂,
    -sinθ₁ * cosθ₃ + cosθ₁ * sinθ₂ * sinθ₃,
    cosθ₁ * cosθ₃ + sinθ₁ * sinθ₂ * sinθ₃,
    cosθ₂ * sinθ₃,
    sinθ₁ * sinθ₃ + cosθ₁ * sinθ₂ * cosθ₃,
    cosθ₁ * -sinθ₃ + sinθ₁ * sinθ₂ * cosθ₃,
    cosθ₂ * cosθ₃
  )
end

function Base.:*(r::IndustryRotation, v::StaticVector)
  if length(v) != 3
    throw("Dimension mismatch: cannot rotate a vector of length $(length(v))")
  end

  θ₁, θ₂, θ₃ = rotparams(r)

  sinθ₁, cosθ₁ = sincos(θ₁)
  sinθ₂, cosθ₂ = sincos(θ₂)
  sinθ₃, cosθ₃ = sincos(θ₃)

  T = Base.promote_op(*, typeof(sinθ₁), eltype(v))

  return similar_type(v, T)(
    cosθ₁ * cosθ₂ * v[1] +
    (-sinθ₁ * cosθ₃ + cosθ₁ * sinθ₂ * sinθ₃) * v[2] +
    (sinθ₁ * sinθ₃ + cosθ₁ * sinθ₂ * cosθ₃) * v[3],
    sinθ₁ * cosθ₂ * v[1] +
    (cosθ₁ * cosθ₃ + sinθ₁ * sinθ₂ * sinθ₃) * v[2] +
    (cosθ₁ * -sinθ₃ + sinθ₁ * sinθ₂ * cosθ₃) * v[3],
    -sinθ₂ * v[1] + cosθ₂ * sinθ₃ * v[2] + cosθ₂ * cosθ₃ * v[3]
  )
end

Base.getindex(r::IndustryRotation, i::Int) = getindex(Tuple(r), i)

"""
    DatamineAngles(α, β, θ)

Datamine ZXY rotation convention following the left-hand rule.
All angles are in degrees and the signal convention is CW, CW, CW
positive. Y is the principal axis.
"""
struct DatamineAngles{T} <: IndustryRotation{T}
  α::T
  β::T
  θ::T
  DatamineAngles{T}(α, β, θ) where {T} = new{rot_eltype(T)}(α, β, θ)
end

DatamineAngles(α::T, β::T, θ::T) where {T} = DatamineAngles{T}(α, β, θ)
DatamineAngles(α, β, θ) = DatamineAngles(promote(α, β, θ)...)

toangles(::Type{<:DatamineAngles}, θ₁, θ₂, θ₃) = (rad2deg(θ₃) + 90, -rad2deg(θ₂), rad2deg(θ₁))

rotparams(r::DatamineAngles) = (deg2rad(r.θ), -deg2rad(r.β), deg2rad(r.α - 90))

"""
    VulcanAngles(α, β, θ)

GSLIB ZYX rotation convention following the right-hand rule.
All angles are in degrees and the signal convention is CW, CCW, CW
positive. X is the principal axis.
"""
struct VulcanAngles{T} <: IndustryRotation{T}
  α::T
  β::T
  θ::T
  VulcanAngles{T}(α, β, θ) where {T} = new{rot_eltype(T)}(α, β, θ)
end

VulcanAngles(α::T, β::T, θ::T) where {T} = VulcanAngles{T}(α, β, θ)
VulcanAngles(α, β, θ) = VulcanAngles(promote(α, β, θ)...)

toangles(::Type{<:VulcanAngles}, θ₁, θ₂, θ₃) = (rad2deg(θ₃) + 90, rad2deg(θ₂), rad2deg(θ₁))

rotparams(r::VulcanAngles) = (deg2rad(r.θ), deg2rad(r.β), deg2rad(r.α - 90))

"""
    GslibAngles(α, β, θ)

GSLIB ZXY rotation convention following the left-hand rule.
All angles are in degrees and the signal convention is CW, CCW, CCW
positive. Y is the principal axis.

## References

* Deutsch, 2015. [The Angle Specification for GSLIB Software]
  (https://geostatisticslessons.com/lessons/anglespecification)
"""
struct GslibAngles{T} <: IndustryRotation{T}
  α::T
  β::T
  θ::T
  GslibAngles{T}(α, β, θ) where {T} = new{rot_eltype(T)}(α, β, θ)
end

GslibAngles(α::T, β::T, θ::T) where {T} = GslibAngles{T}(α, β, θ)
GslibAngles(α, β, θ) = GslibAngles(promote(α, β, θ)...)

toangles(::Type{<:GslibAngles}, θ₁, θ₂, θ₃) = (rad2deg(θ₃) + 90, rad2deg(θ₂), -rad2deg(θ₁))

rotparams(r::GslibAngles) = (-deg2rad(r.θ), deg2rad(r.β), deg2rad(r.α - 90))
