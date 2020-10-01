# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    Ellipsoidal(semiaxes, angles; convention=:TaitBryanExtr)

A distance defined by an ellipsoid with given `semiaxes` and rotation `angles`.
Default angle convention is Tait-Bryan ZXY, extrinsic right-handed rotation
Other conventions available: :TaitBryanIntr, :EulerExtr, :EulerIntr,
                             :GSLIB, :Leapfrog, :Datamine
* :EulerExtr, :EulerIntr and :Datamine assumes ZXZ rotation sequence

- For 2D ellipsoids, there are two semiaxes and one rotation angle.
- For 3D ellipsoids, there are three semiaxes and three rotation angles.

    Ellipsoidal(semiaxes, quaternion)

Alternatively, give the `semiaxes` and the orientation as a `quaternion`

## Examples

2D ellipsoid making 45ᵒ with the horizontal axis:

```julia
julia> Ellipsoidal([1.0,0.5], [π/2])
```

3D ellipsoid rotated by 45ᵒ in the xy plane:

```julia
julia> Ellipsoidal([1.0,0.5,0.5], [π/2,0.0,0.0])
```
"""

# Right-hand rule; motion defined looking to the negative direction of the axis
struct RotationRules
  rot_seq::Symbol
  motion::Vector{Symbol}
  radian::Bool
  main::Symbol
  extrinsic::Bool
end

themes = Dict(
  :TaitBryanExtr => RotationRules(:ZXY,[:CCW,:CCW,:CCW],true,:x,true),
  :TaitBryanIntr => RotationRules(:ZXY,[:CCW,:CCW,:CCW],true,:x,false),
  :EulerExtr => RotationRules(:ZXZ,[:CCW,:CCW,:CCW],true,:x,true),
  :EulerIntr => RotationRules(:ZXZ,[:CCW,:CCW,:CCW],true,:x,false),
  :GSLIB => RotationRules(:ZXY,[:CW,:CCW,:CCW],false,:y,false),
  :Leapfrog => RotationRules(:ZYZ,[:CW,:CW,:CW],false,:x,false),
  :Datamine => RotationRules(:ZXZ,[:CW,:CW,:CW],false,:x,false)
)

struct Ellipsoidal{N,T} <: Metric
  dist::Mahalanobis{T}

  function Ellipsoidal{N,T}(semiaxes, angles; convention=:TaitBryanExtr) where {N,T}
    @assert length(semiaxes) == N "number of semiaxes must match spatial dimension"
    @assert all(semiaxes .> zero(T)) "semiaxes must be positive"
    @assert N ∈ [2,3] "dimension must be either 2 or 3"

    # invert x and y if necessary
    if themes[convention].main == :y
       semiaxes[1], semiaxes[2] = semiaxes[2], semiaxes[1]
    end

    # scaling matrix
    Λ = Diagonal(one(T)./semiaxes.^2)

    # convert to radian if necessary
    angles = themes[convention].radian ? angles : deg2rad.(angles)

    # rotation matrix
    if N == 2
      θ = themes[convention].motion[1] == :CCW ? angles[1] : -1*angles[1]
      P = angle_to_dcm(θ, 0, 0, themes[convention].rot_seq)[1:2,1:2]

    else # N == 3
      for (i,sign) in enumerate(themes[convention].motion)
        angles[i] = sign == :CCW ? angles[i] : -1*angles[i]
      end
      P = angle_to_dcm(angles[1], angles[2], angles[3], themes[convention].rot_seq)
    end

    # ellipsoid matrix
    Q = themes[convention].extrinsic ? P*Λ*P' : P'*Λ*P

    new(Mahalanobis(Q))
  end

  function Ellipsoidal{N,T}(semiaxes, quaternion::Quaternion) where {N,T}
    @assert length(semiaxes) == N "number of semiaxes must match spatial dimension"
    @assert all(semiaxes .> zero(T)) "semiaxes must be positive"
    @assert N ∈ [2,3] "dimension must be either 2 or 3"

    # scaling matrix
    Λ = Diagonal(one(T)./semiaxes.^2)

    # rotation matrix
    if N == 2
      P = quat_to_dcm(quaternion)[1:2,1:2]
    else # N == 3
      P = quat_to_dcm(quaternion)
    end

    # ellipsoid matrix
    Q = P*Λ*P'

    new(Mahalanobis(Q))
  end
end

Ellipsoidal(semiaxes::AbstractVector{T}, angles::AbstractVector{T}; kwargs...) where {T} =
  Ellipsoidal{length(semiaxes),T}(semiaxes, angles; kwargs...)

Ellipsoidal(semiaxes::AbstractVector{T}, quaternion::Quaternion) where {T} =
  Ellipsoidal{length(semiaxes),T}(semiaxes, quaternion)

evaluate(dist::Ellipsoidal{N,T}, a::AbstractVector, b::AbstractVector) where {N,T} =
  evaluate(dist.dist, a, b)
