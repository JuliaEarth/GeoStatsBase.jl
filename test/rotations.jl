@testset "Rotations" begin
    v₁ = [3, 2, 1]
    v₂ = [0.5, 0.8, 0.1]

    # Datamine convention
    datamine_angles = DatamineAngles(70, 30, -20)
    datamine_dcm = angle_to_dcm(datamine_angles)

    @test datamine_dcm * v₁ ≈ [2.533789309500169, 1.6971296470206085, 2.1678705441668704]
    @test datamine_dcm * v₂ ≈ [0.593857346855506, 0.7024802506855807, 0.2320666908077572]

    # GSLIB convention
    gslib_angles = GslibAngles(70, -30, 20)
    gslib_dcm = angle_to_dcm(gslib_angles)

    @test gslib_dcm * v₁ ≈ [2.533789309500169, 1.6971296470206085, 2.1678705441668704]
    @test gslib_dcm * v₂ ≈ [0.593857346855506, 0.7024802506855807, 0.2320666908077572]

    # Vulcan convention
    vulcan_angles = VulcanAngles(70, -30, -20)
    vulcan_dcm = angle_to_dcm(vulcan_angles)

    @test vulcan_dcm * v₁ ≈ [2.533789309500169, 1.6971296470206085, 2.1678705441668704]
    @test vulcan_dcm * v₂ ≈ [0.593857346855506, 0.7024802506855807, 0.2320666908077572]

    # comparing conventions
    @test datamine_dcm ≈ gslib_dcm
    @test datamine_dcm ≈ vulcan_dcm
    @test gslib_dcm ≈ vulcan_dcm 
end