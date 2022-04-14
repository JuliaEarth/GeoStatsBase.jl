@testset "Weighting" begin
  @testset "UniformWeighting" begin
    d = CartesianGrid(100,100)
    s = georef((z=rand(100,100),))
    for o in [d, s]
      w = weight(o, UniformWeighting())
      @test length(w) == nelements(o)
      @test all(w .== 1)
    end
  end

  @testset "BlockWeighting" begin
    d = CartesianGrid(100,100)
    s = georef((z=rand(100,100),))
    for o in [d, s]
      w = weight(o, BlockWeighting(10.,10.))
      @test length(unique(w)) == 1
      @test w[1] == 1 / 100
    end
  end

  @testset "DensityRatioWeighting" begin
    rng = MersenneTwister(123)

    r1 = Normal(0, 2)
    r2 = MixtureModel([Normal(-2,1), Normal(2,2)], [0.2, 0.8])

    n  = 1000
    z1 = sort(rand(rng, r1, n))
    z2 = sort(rand(rng, r2, n))

    d1 = georef((z=z1,), PointSet(reshape(1:n,1,:)))
    d2 = georef((z=z2,), PointSet(reshape(1:n,1,:)))

    dre = LSIF(rng=rng)

    w = weight(d1, DensityRatioWeighting(d2, estimator=dre))

    if visualtests
      plt = plot(z1, pdf.(r1, z1), size=(800,400), label="source")
      plot!(z1, pdf.(r2, z1), label="target")
      plot!(z1, w .* pdf.(r1, z1), label="approx")
      @test_reference "data/densratio.png" plt
    end
  end
end
