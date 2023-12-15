@testset "Macros" begin
  @testset "@estimsolver" begin
    s = ESolver(:z => (A=2, B=3), C=false)
    @test s.C == false
    @test s.progress == true
    @test targets(s) == [:z]
    names, params = covariables(:z, s)
    @test names == Set([:z])
    @test params[Set([:z])].A == 2
    @test params[Set([:z])].B == 3

    @test sprint(show, s) == "ESolver"
    @test sprint(show, MIME"text/plain"(), s) == "ESolver\n└─z\n  └─A: 2\n  └─B: 3\n"
  end
end
