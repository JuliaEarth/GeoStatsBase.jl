# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    DatamineAngles(α, β, θ)

Datamine ZXY rotation convention following the left-hand rule.
All angles are in degrees and the signal convention is CW, CW, CW
positive. Y is the principal axis.
"""
DatamineAngles(α, β, θ) = RotZYX(deg2rad(θ), -deg2rad(β), deg2rad(α - 90))

"""
    VulcanAngles(α, β, θ)

GSLIB ZYX rotation convention following the right-hand rule.
All angles are in degrees and the signal convention is CW, CCW, CW
positive. X is the principal axis.
"""
VulcanAngles(α, β, θ) = RotZYX(deg2rad(θ), deg2rad(β), deg2rad(α - 90))

"""
    GslibAngles(α, β, θ)

GSLIB ZXY rotation convention following the left-hand rule.
All angles are in degrees and the signal convention is CW, CCW, CCW
positive. Y is the principal axis.

## References

* Deutsch, 2015. [The Angle Specification for GSLIB Software]
  (https://geostatisticslessons.com/lessons/anglespecification)
"""
GslibAngles(α, β, θ) = RotZYX(-deg2rad(θ), deg2rad(β), deg2rad(α - 90))
