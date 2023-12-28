@testset "Rotations" begin
  v₁ = [3, 2, 1]
  v₂ = [0.5, 0.8, 0.1]

  # Datamine convention
  datamine = DatamineAngles(70, 30, -20)

  @test datamine * v₁ ≈ [3.0810411262386967, 1.2425629737653001, 1.7214014158973259]
  @test datamine * v₂ ≈ [0.7601180732526871, 0.5597366702348654, 0.09442126195411826]

  # GSLIB convention
  gslib = GslibAngles(70, -30, 20)

  @test gslib * v₁ ≈ [3.0810411262386967, 1.2425629737653001, 1.7214014158973259]
  @test gslib * v₂ ≈ [0.7601180732526871, 0.5597366702348654, 0.09442126195411826]

  # Vulcan convention
  vulcan = VulcanAngles(70, -30, -20)

  @test vulcan * v₁ ≈ [3.0810411262386967, 1.2425629737653001, 1.7214014158973259]
  @test vulcan * v₂ ≈ [0.7601180732526871, 0.5597366702348654, 0.09442126195411826]

  # comparing conventions
  @test datamine ≈ gslib
  @test datamine ≈ vulcan
  @test gslib ≈ vulcan

  # rotation conversion
  rot = RotZXY(0.1, 0.2, 0.3)
  @test DatamineAngles(rot) ≈ GslibAngles(rot) ≈ VulcanAngles(rot) ≈ rot

  θ₁, θ₂, θ₃ = -15, 45, 30
  rot = RotZYX(deg2rad(θ₃), -deg2rad(θ₂), deg2rad(θ₁ - 90))
  datamine = DatamineAngles(rot)
  @test Rotations.params(datamine) ≈ [θ₁, θ₂, θ₃]

  rot = RotZYX(deg2rad(θ₃), deg2rad(θ₂), deg2rad(θ₁ - 90))
  vulcan = VulcanAngles(rot)
  @test Rotations.params(vulcan) ≈ [θ₁, θ₂, θ₃]

  rot = RotZYX(-deg2rad(θ₃), deg2rad(θ₂), deg2rad(θ₁ - 90))
  gslib = GslibAngles(rot)
  @test Rotations.params(gslib) ≈ [θ₁, θ₂, θ₃]
end
