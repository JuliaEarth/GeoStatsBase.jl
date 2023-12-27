# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

abstract type GeoStatsRotation{T} <: Rotation{3,T} end

(::Type{Rot})(t::NTuple{9}) where {Rot<:GeoStatsRotation} = Rot(RotZYX(t))

Base.getindex(r::GeoStatsRotation, i::Int) = getindex(r.rot, i)

Base.Tuple(r::GeoStatsRotation) = Tuple(r.rot)

Base.:*(r::GeoStatsRotation, v::StaticVector) = r.rot * v

function Base.show(io::IO, ::MIME"text/plain", r::GeoStatsRotation)
  ioctx = IOContext(io, :compact => true)
  summary(ioctx, r)
  println(ioctx, ":")
  Base.print_array(ioctx, r)
end

"""
    DatamineAngles(α, β, θ)

Datamine ZXY rotation convention following the left-hand rule.
All angles are in degrees and the signal convention is CW, CW, CW
positive. Y is the principal axis.
"""
struct DatamineAngles{T} <: GeoStatsRotation{T}
  rot::RotZYX{T}
  DatamineAngles{T}(rot::RotZYX{T}) where {T} = new(rot)
  DatamineAngles(rot::RotZYX{T}) where {T} = new{T}(rot)
end

DatamineAngles(α, β, θ) = DatamineAngles(RotZYX(deg2rad(θ), -deg2rad(β), deg2rad(α - 90)))

"""
    VulcanAngles(α, β, θ)

GSLIB ZYX rotation convention following the right-hand rule.
All angles are in degrees and the signal convention is CW, CCW, CW
positive. X is the principal axis.
"""
struct VulcanAngles{T} <: GeoStatsRotation{T}
  rot::RotZYX{T}
  VulcanAngles{T}(rot::RotZYX{T}) where {T} = new(rot)
  VulcanAngles(rot::RotZYX{T}) where {T} = new{T}(rot)
end

VulcanAngles(α, β, θ) = VulcanAngles(RotZYX(deg2rad(θ), deg2rad(β), deg2rad(α - 90)))

"""
    GslibAngles(α, β, θ)

GSLIB ZXY rotation convention following the left-hand rule.
All angles are in degrees and the signal convention is CW, CCW, CCW
positive. Y is the principal axis.

## References

* Deutsch, 2015. [The Angle Specification for GSLIB Software]
  (https://geostatisticslessons.com/lessons/anglespecification)
"""
struct GslibAngles{T} <: GeoStatsRotation{T}
  rot::RotZYX{T}
  GslibAngles{T}(rot::RotZYX{T}) where {T} = new(rot)
  GslibAngles(rot::RotZYX{T}) where {T} = new{T}(rot)
end

GslibAngles(α, β, θ) = GslibAngles(RotZYX(-deg2rad(θ), deg2rad(β), deg2rad(α - 90)))
