@testset "Rotations" begin
  v₁ = [3, 2, 1]
  v₂ = [0.5, 0.8, 0.1]

  # Datamine convention
  datamine = DatamineAngles(70, 30, -20)

  @test datamine * v₁ ≈ [3.0810411262386967, 1.2425629737653001, 1.7214014158973259]
  @test datamine * v₂ ≈ [0.7601180732526871, 0.5597366702348654, 0.09442126195411826]

  # Vulcan convention
  vulcan = VulcanAngles(70, -30, -20)

  @test vulcan * v₁ ≈ [3.0810411262386967, 1.2425629737653001, 1.7214014158973259]
  @test vulcan * v₂ ≈ [0.7601180732526871, 0.5597366702348654, 0.09442126195411826]

  # GSLIB convention
  gslib = GslibAngles(30, 15, -15)

  @test gslib * v₁ ≈ [3.7410191941252595, -0.034675177060507156, 0.059774754555877996]
  @test gslib * v₂ ≈ [0.8592918193713616, 0.4018496819077273, -0.011593201115905286]

  # MineSight convention
  minesight = MinesightAngles(30, 15, -15)

  @test minesight * v₁ ≈ [3.7410191941252595, -0.034675177060507156, 0.059774754555877996]
  @test minesight * v₂ ≈ [0.8592918193713616, 0.4018496819077273, -0.011593201115905286]

  # comparing conventions
  @test datamine ≈ vulcan
  @test gslib ≈ minesight

  # rotation conversion
  rot = RotZXY(0.1, 0.2, 0.3)
  @test DatamineAngles(rot) ≈ VulcanAngles(rot) ≈ rot

  θ₁, θ₂, θ₃ = -15, 45, 30
  rot = RotZYX(deg2rad(θ₃), -deg2rad(θ₂), deg2rad(θ₁ - 90))
  datamine = DatamineAngles(rot)
  @test Rotations.params(datamine) ≈ [θ₁, θ₂, θ₃]

  rot = RotZYX(deg2rad(θ₃), deg2rad(θ₂), deg2rad(θ₁ - 90))
  vulcan = VulcanAngles(rot)
  @test Rotations.params(vulcan) ≈ [θ₁, θ₂, θ₃]

  θ₁, θ₂, θ₃ = 30, 15, -15
  rot = RotYXZ(-deg2rad(θ₃), deg2rad(θ₂), -deg2rad(θ₁))
  gslib = GslibAngles(rot)
  minesight = MinesightAngles(rot)
  @test gslib ≈ minesight ≈ rot
  @test Rotations.params(gslib) ≈ [θ₁, θ₂, θ₃]
  @test Rotations.params(minesight) ≈ [θ₁, θ₂, θ₃]
end
