@testset "Plotting" begin
  Random.seed!(123)
  z₁ = randn(10000)
  z₂ = z₁ + randn(10000)
  d = georef(DataFrame(z₁=z₁,z₂=z₂), RegularGrid(100,100))

  @testset "DistPlot1D" begin
    if visualtests
      @test_ref_plot "data/distplot1D.png" distplot1d(d,:z₁)
    end
  end

  @testset "DistPlot2D" begin
    if visualtests
      @test_ref_plot "data/distplot2D.png" distplot2d(d,:z₁,:z₂)
    end
  end

  @testset "CornerPlot" begin
    if visualtests
      @test_ref_plot "data/cornerplot.png" cornerplot(d)
    end
  end

  @testset "HScatter" begin
    if visualtests
      sdata = readgeotable(joinpath(datadir,"samples2D.tsv"), coordnames=(:x,:y))
      p0 = hscatter(sdata, :value, lag=0)
      p1 = hscatter(sdata, :value, lag=1)
      p2 = hscatter(sdata, :value, lag=2)
      p3 = hscatter(sdata, :value, lag=3)
      plt = plot(p0, p1, p2, p3, layout=(2,2), size=(600,600))
      @test_ref_plot "data/hscatter.png" plt
    end
  end
end
