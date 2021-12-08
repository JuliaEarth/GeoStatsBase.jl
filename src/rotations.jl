# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    DatamineAngles(α, β, θ)

Datamine ZXY rotation convention following the left-hand rule.
All angles are in degrees and the signal convention is CW, CW, CW
positive. Y is the principal axis.
"""

function DatamineAngles(α, β, θ)
    EulerAngles(-deg2rad(α - 90), deg2rad(β), -deg2rad(θ), :ZYX)
end

"""
    GslibAngles(α, β, θ)

GSLIB ZXY rotation convention following the left-hand rule.
All angles are in degrees and the signal convention is CW, CCW, CCW
positive. Y is the principal axis.

## Reference
* Deutsch, 2015. [The Angle Specification for GSLIB Software]
(https://geostatisticslessons.com/lessons/anglespecification)
"""

function GslibAngles(α, β, θ)
    EulerAngles(-deg2rad(α - 90), -deg2rad(β), deg2rad(θ), :ZYX)
end

"""
    VulcanAngles(α, β, θ)

GSLIB ZYX rotation convention following the right-hand rule.
All angles are in degrees and the signal convention is CW, CCW, CW
positive. X is the principal axis.

## Reference
* Deutsch, 2015. [The Angle Specification for GSLIB Software]
(https://geostatisticslessons.com/lessons/anglespecification)
"""

function VulcanAngles(α, β, θ)
    EulerAngles(-deg2rad(α - 90), -deg2rad(β), -deg2rad(θ), :ZYX)
end