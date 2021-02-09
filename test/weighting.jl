@testset "Weighting" begin
  @testset "UniformWeighting" begin
    d = RegularGrid(100,100)
    s = georef((z=rand(100,100),))
    for o in [d, s]
      w = weight(o, UniformWeighting())
      @test length(w) == nelms(o)
      @test all(w .== 1)
    end
  end

  @testset "BlockWeighting" begin
    d = RegularGrid(100,100)
    s = georef((z=rand(100,100),))
    for o in [d, s]
      w = weight(o, BlockWeighting(10,10))
      @test length(unique(w)) == 1
      @test w[1] == 1 / 100
    end
  end

  @testset "DensityRatioWeighting" begin
    n = 1000; Random.seed!(123)

    r1 = Normal(0, 2)
    r2 = MixtureModel([Normal(-2,1), Normal(2,2)], [0.2, 0.8])

    z1 = sort(rand(r1, n))
    z2 = sort(rand(r2, n))

    d1 = georef(DataFrame(z=z1), PointSet(reshape(1:n,1,:)))
    d2 = georef(DataFrame(z=z2), PointSet(reshape(1:n,1,:)))

    w = weight(d1, DensityRatioWeighting(d2))

    if visualtests
      plt = plot(z1, pdf.(r1, z1), size=(800,400), label="source")
      plot!(z1, pdf.(r2, z1), label="target")
      plot!(z1, w .* pdf.(r1, z1), label="approx")
      @test_ref_plot "data/densratio.png" plt
    end
  end
end
