# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    Ellipsoidal(semiaxes, angles)

A distance defined by an ellipsoid with given `semiaxes` and rotation `angles`.

- For 2D ellipsoids, there are two semiaxes and one rotation angle.
- For 3D ellipsoids, there are three semiaxes and three rotation angles.

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

# Right-hand rule; signs when looking in the negative direction of the axis
struct RotationRules
  axes::Vector{Symbol}
  rot::Vector{Symbol}
end

conventions = Dict(
  :TaitBryan => RotationRules([:z,:x,:y],[:CCW,:CCW,:CCW]),
  :Euler => RotationRules([:z,:x,:z],[:CCW,:CCW,:CCW]),
  :GSLIB => RotationRules([:z,:x,:y],[:CW,:CCW,:CCW]),
  :Leapfrog => RotationRules([:z,:y,:z],[:CW,:CCW,:CCW]),
  :Vulcan => RotationRules([:z,:y,:x],[:CW,:CCW,:CW]),
  :Datamine => RotationRules([:z,:x,:z],[:CW,:CW,:CW]) # assumes 3,1,3
)

struct Ellipsoidal{N,T} <: Metric
  dist::Mahalanobis{T}

  function Ellipsoidal{N,T}(semiaxes, angles; order=:TaitBryan) where {N,T}
    @assert length(semiaxes) == N "number of semiaxes must match spatial dimension"
    @assert all(semiaxes .> zero(T)) "semiaxes must be positive"
    @assert N ∈ [2,3] "dimension must be either 2 or 3"

    # scaling matrix
    Λ = Diagonal(one(T)./semiaxes.^2)

    # rotation matrix
    if N == 2
      θ = conventions[order].rot[1] == :CCW ? angles[1] : -1*angles[1]

      cosθ = cos(θ)
      sinθ = sin(θ)

      P = @SMatrix [cosθ -sinθ
           sinθ  cosθ]
    end
    if N == 3
      R = []
      println(conventions[order].axes)

      for (i,ax) in enumerate(conventions[order].axes)

        θ = conventions[order].rot[i] == :CCW ? angles[i] : -1*angles[i]

        cosx = cos(θ)
        sinx = sin(θ)
        _1 = one(T)
        _0 = zero(T)

        if ax == :z
          Ri = @SMatrix [cosx -sinx _0
                 sinx  cosx _0
                 _0     _0 _1]
        elseif ax == :x
          Ri = @SMatrix [_1    _0     _0
                 _0 cosx -sinx
                 _0 sinx  cosx]
        else
          Ri = @SMatrix [ cosx _0 sinx
                 _0 _1    _0
                 -sinx _0 cosx]
        end
        push!(R,Ri)
      end
      P = R[3]*R[2]*R[1]
    end

    println(P)

    # ellipsoid matrix
    Q = P*Λ*P'

    new(Mahalanobis(Q))
  end
end

Ellipsoidal(semiaxes::AbstractVector{T}, angles::AbstractVector{T}; kwargs...) where {T} =
  Ellipsoidal{length(semiaxes),T}(semiaxes, angles; kwargs...)

evaluate(dist::Ellipsoidal{N,T}, a::AbstractVector, b::AbstractVector) where {N,T} =
  evaluate(dist.dist, a, b)
