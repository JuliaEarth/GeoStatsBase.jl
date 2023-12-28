# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

abstract type IndustryRotation{T} <: Rotation{3,T} end

"""
    rottype(R::Type{<:IndustryRotation}) -> Rotation

Returns the equivalent rotation of the idustry rotation `R`.
"""
rottype(::Type{<:IndustryRotation}) = RotZYX

Rotations.params(r::IndustryRotation) = SVector(r.θ₁, r.θ₂, r.θ₃)

(::Type{R})(t::NTuple{9}) where {R<:IndustryRotation} = convert(R, rottype(R)(t))

Base.Tuple(r::R) where {R<:IndustryRotation} = Tuple(convert(rottype(R), r))

function Base.:*(r::R, v::StaticVector) where {R<:IndustryRotation}
  if length(v) != 3
    throw("Dimension mismatch: cannot rotate a vector of length $(length(v))")
  end
  rot = convert(rottype(R), r)
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
  θ₁::T
  θ₂::T
  θ₃::T
  DatamineAngles{T}(θ₁, θ₂, θ₃) where {T} = new{rot_eltype(T)}(θ₁, θ₂, θ₃)
end

DatamineAngles(θ₁::T, θ₂::T, θ₃::T) where {T} = DatamineAngles{T}(θ₁, θ₂, θ₃)
DatamineAngles(θ₁, θ₂, θ₃) = DatamineAngles(promote(θ₁, θ₂, θ₃)...)

function Base.convert(::Type{R}, rot::RotZYX) where {R<:DatamineAngles}
  θ₁, θ₂, θ₃ = Rotations.params(rot)
  R(rad2deg(θ₃) + 90, -rad2deg(θ₂), rad2deg(θ₁))
end

function Base.convert(::Type{R}, rot::DatamineAngles) where {R<:RotZYX}
  (; θ₁, θ₂, θ₃) = rot
  R(deg2rad(θ₃), -deg2rad(θ₂), deg2rad(θ₁ - 90))
end

"""
    VulcanAngles(θ₁, θ₂, θ₃)

GSLIB ZYX rotation convention following the right-hand rule.
All angles are in degrees and the signal convention is CW, CCW, CW
positive. X is the principal axis.
"""
struct VulcanAngles{T} <: IndustryRotation{T}
  θ₁::T
  θ₂::T
  θ₃::T
  VulcanAngles{T}(θ₁, θ₂, θ₃) where {T} = new{rot_eltype(T)}(θ₁, θ₂, θ₃)
end

VulcanAngles(θ₁::T, θ₂::T, θ₃::T) where {T} = VulcanAngles{T}(θ₁, θ₂, θ₃)
VulcanAngles(θ₁, θ₂, θ₃) = VulcanAngles(promote(θ₁, θ₂, θ₃)...)

function Base.convert(::Type{R}, rot::RotZYX) where {R<:VulcanAngles}
  θ₁, θ₂, θ₃ = Rotations.params(rot)
  R(rad2deg(θ₃) + 90, rad2deg(θ₂), rad2deg(θ₁))
end

function Base.convert(::Type{R}, rot::VulcanAngles) where {R<:RotZYX}
  (; θ₁, θ₂, θ₃) = rot
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
  θ₁::T
  θ₂::T
  θ₃::T
  GslibAngles{T}(θ₁, θ₂, θ₃) where {T} = new{rot_eltype(T)}(θ₁, θ₂, θ₃)
end

GslibAngles(θ₁::T, θ₂::T, θ₃::T) where {T} = GslibAngles{T}(θ₁, θ₂, θ₃)
GslibAngles(θ₁, θ₂, θ₃) = GslibAngles(promote(θ₁, θ₂, θ₃)...)

function Base.convert(::Type{R}, rot::RotZYX) where {R<:GslibAngles}
  θ₁, θ₂, θ₃ = Rotations.params(rot)
  R(rad2deg(θ₃) + 90, rad2deg(θ₂), -rad2deg(θ₁))
end

function Base.convert(::Type{R}, rot::GslibAngles) where {R<:RotZYX}
  (; θ₁, θ₂, θ₃) = rot
  R(-deg2rad(θ₃), deg2rad(θ₂), deg2rad(θ₁ - 90))
end

"""
    MinesightAngles(θ₁, θ₂, θ₃)

MineSight YZX rotation convention following the right-hand rule.
All angles are in degrees and the signal convention is CW, CCW, CW positive.

The first rotation is a horizontal rotation around the Z-axis, with positive being clockwise.
The second rotation is a rotation around the new X-axis, which moves the Y-axis into the
desired position, with positive direction of rotation is up.
The third rotation is a rotation around the new Y-axis, which moves the X-axis into the 
desired position, with positive direction of rotation is up.

## References

* MINESIGHT® TUTORIALS (https://pdfcoffee.com/manual-minesight-6-pdf-free.html)
"""
struct MinesightAngles{T} <: IndustryRotation{T}
  θ₁::T
  θ₂::T
  θ₃::T
  MinesightAngles{T}(θ₁, θ₂, θ₃) where {T} = new{rot_eltype(T)}(θ₁, θ₂, θ₃)
end

MinesightAngles(θ₁::T, θ₂::T, θ₃::T) where {T} = MinesightAngles{T}(θ₁, θ₂, θ₃)
MinesightAngles(θ₁, θ₂, θ₃) = MinesightAngles(promote(θ₁, θ₂, θ₃)...)

rottype(::Type{<:MinesightAngles}) = RotYXZ

function Base.convert(::Type{R}, rot::RotYXZ) where {R<:MinesightAngles}
  θ₁, θ₂, θ₃ = Rotations.params(rot)
  R(-rad2deg(θ₃), rad2deg(θ₂), -rad2deg(θ₁))
end

function Base.convert(::Type{R}, rot::MinesightAngles) where {R<:RotYXZ}
  (; θ₁, θ₂, θ₃) = rot
  R(-deg2rad(θ₃), deg2rad(θ₂), -deg2rad(θ₁))
end
