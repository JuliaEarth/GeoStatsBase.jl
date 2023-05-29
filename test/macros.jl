@testset "Macros" begin
  @testset "@estimsolver" begin
    s = ESolver(:z => (A=2, B=3), C=false)
    @test s.C == false
    @test s.progress == true
    @test targets(s) == [:z]
    names, params = covariables(:z, s)
    @test names == (:z,)
    @test params[(:z,)].A == 2
    @test params[(:z,)].B == 3

    @test sprint(show, s) == "ESolver"
    @test sprint(show, MIME"text/plain"(), s) == "ESolver\n  └─z\n    └─A ⇨ 2\n    └─B ⇨ 3\n"
  end

  @testset "@simsolver" begin
    s = SSolver(:z => (A=2, B=3), C=false)
    @test s.C == false
    @test targets(s) == [:z]
    names, params = covariables(:z, s)
    @test names == (:z,)
    @test params[(:z,)].A == 2
    @test params[(:z,)].B == 3

    @test sprint(show, s) == "SSolver"
    @test sprint(show, MIME"text/plain"(), s) == "SSolver\n  └─z\n    └─A ⇨ 2\n    └─B ⇨ 3\n"

    s = SSolver()
    @test s.C == true
    @test s.progress == true
    @test isempty(targets(s))
    names, params = covariables(:z, s)
    @test names == (:z,)
    @test params[(:z,)].A == 1.0
    @test params[(:z,)].B == 2
    s = SSolver(progress=false)
    @test s.progress == false

    s = SSolver(:z => (A=1, B=2), :w => (A=2, B=3), (:z, :w) => (J="bar",))
    @test s.C == true
    @test Set(targets(s)) == Set([:z, :w])
    names, params = covariables(:z, s)
    @test Set(names) == Set((:z, :w))
    @test params[(:z,)].A == 1
    @test params[(:z,)].B == 2
    @test params[(:w,)].A == 2
    @test params[(:w,)].B == 3
    @test params[(:z, :w)].J == "bar"
  end
end
