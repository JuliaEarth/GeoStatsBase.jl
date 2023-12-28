# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

abstract type IndustryRotation{T} <: Rotation{3,T} end

Rotations.params(r::IndustryRotation) = SVector(r.theta1, r.theta2, r.theta3)

(::Type{R})(t::NTuple{9}) where {R<:IndustryRotation} = convert(R, RotZYX(t))

Base.Tuple(r::IndustryRotation) = Tuple(convert(RotZYX, r))

function Base.:*(r::IndustryRotation, v::StaticVector)
  if length(v) != 3
    throw("Dimension mismatch: cannot rotate a vector of length $(length(v))")
  end
  rot = convert(RotZYX, r)
  rot * v
end

Base.getindex(r::IndustryRotation, i::Int) = getindex(Tuple(r), i)

"""
    DatamineAngles(θ₁, θ₂, θ₃)

Datamine ZXY rotation convention following the left-hand rule.
All angles are in degrees and the signal convention is CW, CW, CW
positive. Y is the principal axis.
"""
struct DatamineAngles{T} <: IndustryRotation{T}
  theta1::T
  theta2::T
  theta3::T
  DatamineAngles{T}(theta1, theta2, theta3) where {T} = new{rot_eltype(T)}(theta1, theta2, theta3)
end

DatamineAngles(theta1::T, theta2::T, theta3::T) where {T} = DatamineAngles{T}(theta1, theta2, theta3)
DatamineAngles(theta1, theta2, theta3) = DatamineAngles(promote(theta1, theta2, theta3)...)

function Base.convert(::Type{R}, rot::RotZYX) where {R<:DatamineAngles}
  θ₁, θ₂, θ₃ = Rotations.params(rot)
  R(rad2deg(θ₃) + 90, -rad2deg(θ₂), rad2deg(θ₁))
end

function Base.convert(::Type{R}, rot::DatamineAngles) where {R<:RotZYX}
  θ₁, θ₂, θ₃ = Rotations.params(rot)
  R(deg2rad(θ₃), -deg2rad(θ₂), deg2rad(θ₁ - 90))
end

"""
    VulcanAngles(θ₁, θ₂, θ₃)

GSLIB ZYX rotation convention following the right-hand rule.
All angles are in degrees and the signal convention is CW, CCW, CW
positive. X is the principal axis.
"""
struct VulcanAngles{T} <: IndustryRotation{T}
  theta1::T
  theta2::T
  theta3::T
  VulcanAngles{T}(theta1, theta2, theta3) where {T} = new{rot_eltype(T)}(theta1, theta2, theta3)
end

VulcanAngles(theta1::T, theta2::T, theta3::T) where {T} = VulcanAngles{T}(theta1, theta2, theta3)
VulcanAngles(theta1, theta2, theta3) = VulcanAngles(promote(theta1, theta2, theta3)...)

function Base.convert(::Type{R}, rot::RotZYX) where {R<:VulcanAngles}
  θ₁, θ₂, θ₃ = Rotations.params(rot)
  R(rad2deg(θ₃) + 90, rad2deg(θ₂), rad2deg(θ₁))
end

function Base.convert(::Type{R}, rot::VulcanAngles) where {R<:RotZYX}
  θ₁, θ₂, θ₃ = Rotations.params(rot)
  R(deg2rad(θ₃), deg2rad(θ₂), deg2rad(θ₁ - 90))
end

"""
    GslibAngles(θ₁, θ₂, θ₃)

GSLIB ZXY rotation convention following the left-hand rule.
All angles are in degrees and the signal convention is CW, CCW, CCW
positive. Y is the principal axis.

## References

* Deutsch, 2015. [The Angle Specification for GSLIB Software]
  (https://geostatisticslessons.com/lessons/anglespecification)
"""
struct GslibAngles{T} <: IndustryRotation{T}
  theta1::T
  theta2::T
  theta3::T
  GslibAngles{T}(theta1, theta2, theta3) where {T} = new{rot_eltype(T)}(theta1, theta2, theta3)
end

GslibAngles(theta1::T, theta2::T, theta3::T) where {T} = GslibAngles{T}(theta1, theta2, theta3)
GslibAngles(theta1, theta2, theta3) = GslibAngles(promote(theta1, theta2, theta3)...)

function Base.convert(::Type{R}, rot::RotZYX) where {R<:GslibAngles}
  θ₁, θ₂, θ₃ = Rotations.params(rot)
  R(rad2deg(θ₃) + 90, rad2deg(θ₂), -rad2deg(θ₁))
end

function Base.convert(::Type{R}, rot::GslibAngles) where {R<:RotZYX}
  θ₁, θ₂, θ₃ = Rotations.params(rot)
  R(-deg2rad(θ₃), deg2rad(θ₂), deg2rad(θ₁ - 90))
end
