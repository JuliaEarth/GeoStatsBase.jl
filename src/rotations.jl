# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    Datamine(α, β, θ)

Datamine ZXY rotation convention following the left-hand rule.
All angles are in degrees and the signal convention is CW, CW, CW
positive.
"""

function Datamine(α, β, θ)
    EulerAngles(-deg2rad(α - 90), deg2rad(β), -deg2rad(θ), :ZYX)
end

"""
    Gslib(α, β, θ)

GSLIB ZXY rotation convention following the left-hand rule.
All angles are in degrees and the signal convention is CW, CCW, CCW
positive.
"""

function Gslib(α, β, θ)
    EulerAngles(-deg2rad(α - 90), -deg2rad(β), deg2rad(θ), :ZYX)
end