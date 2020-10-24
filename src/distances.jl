# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    RotationRule(order, motion, radian, main, extrinsic)

Creates a rule for the ellipsoidal rotation

## Parameters

    * order     - sequence of three axes by which the rotations are made; e.g. `:ZXZ`
    * motion    - inform for each of the three rotations if it is clockwise (`:CW`) or
                  counterclockwise (`:CCW`). Right-hand rule: motion defined looking
                  towards the negative direction of the axis
    * radian    - `true` if the input angles are in radians or `false` if in degrees
    * main      - inform if the main semiaxis is `:x` or `:y`
    * extrinsic - `true` if rotation is extrinsic or `false` if it is intrinsic

## Example

Rotation rule to reproduce GSLIB rotation:

```julia
julia> rule = RotationRule(:ZXY,[:CW,:CCW,:CCW],false,:y,false)
```
"""
struct RotationRule
  order::Symbol
  motion::Vector{Symbol}
  radian::Bool
  main::Symbol
  extrinsic::Bool
end

# list of available rotation rules
rules = Dict(
  :TaitBryanExtr => RotationRule(:ZXY,[:CCW,:CCW,:CCW],true,:x,true),
  :TaitBryanIntr => RotationRule(:ZXY,[:CCW,:CCW,:CCW],true,:x,false),
  :EulerExtr     => RotationRule(:ZXZ,[:CCW,:CCW,:CCW],true,:x,true),
  :EulerIntr     => RotationRule(:ZXZ,[:CCW,:CCW,:CCW],true,:x,false),
  :GSLIB         => RotationRule(:ZXY,[:CW,:CCW,:CCW],false,:y,false),
  :Leapfrog      => RotationRule(:ZXZ,[:CW,:CW,:CW],false,:x,false),
  :Datamine      => RotationRule(:ZXZ,[:CW,:CW,:CW],false,:x,false)
)

"""
    aniso2distance(semiaxes, angles; convention=:TaitBryanExtr)

A distance defined by an ellipsoid with given `semiaxes` and rotation `angles`.

- For 2D ellipsoids, there are two semiaxes and one rotation angle.
- For 3D ellipsoids, there are three semiaxes and three rotation angles.

## Conventions

Different rotation conventions can be passed via the `convention` option:

- :TaitBryanExtr => Extrinsic right-handed rotation by the ZXY axes
- :TaitBryanIntr => Intrinsic right-handed rotation by the ZXY axes
- :EulerExtr     => Extrinsic right-handed rotation by the ZXZ axes
- :EulerIntr     => Intrinsic right-handed rotation by the ZXZ axes
- :GSLIB         => GSLIB software rotation convention
- :Leapfrog      => LeapFrog software rotation convention
- :Datamine      => Datamine software rotation convention (fixed to ZXZ axes)

Tait-Bryan and Euler conventions expect angles in radians.
The other conventions expect them in degrees.

Default convention is `:TaitBryanExtr`.

## Examples

2D ellipsoid making 45ᵒ with the horizontal axis:

```julia
julia> aniso2distance([1.0,0.5], [π/2])
```

3D ellipsoid rotated by 45ᵒ in the xy plane:

```julia
julia> aniso2distance([1.0,0.5,0.5], [π/2,0.0,0.0])
```
"""
function aniso2distance(semiaxes::AbstractVector, angles::AbstractVector;
  convention::Symbol=:TaitBryanExtr)

  N = length(semiaxes)
  @assert all(semiaxes .> 0) "semiaxes must be positive"
  @assert N ∈ [2,3] "dimension must be either 2 or 3"

  rule = rules[convention]

  # invert x and y if necessary
  if rule.main == :y
     semiaxes[1], semiaxes[2] = semiaxes[2], semiaxes[1]
  end

  # scaling matrix
  Λ = Diagonal(SVector{N}(one(eltype(semiaxes))./semiaxes.^2))

  # convert to radian and invert sign if necessary
  !rule.radian && (angles = deg2rad.(angles))
  _0 = zero(eltype(angles))
  N == 2 && (angles = [angles[1], _0, _0])
  intr = @. (rule.motion == :CW) & !rule.extrinsic
  extr = @. (rule.motion == :CCW) & rule.extrinsic
  angles[intr .| extr] *= -1

  # rotation matrix
  P = angle_to_dcm(angles..., rule.order)[SOneTo(N),SOneTo(N)]

  # ellipsoid matrix
  Q = rule.extrinsic ? P*Λ*P' : P'*Λ*P

  Mahalanobis(Q)
end
