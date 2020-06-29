@testset "Plotting" begin
  Random.seed!(123)
  z₁ = randn(10000)
  z₂ = z₁ + randn(10000)
  d = georef(DataFrame(z₁=z₁,z₂=z₂), RegularGrid(100,100))

  @testset "DistPlot1D" begin
    if visualtests
      @plottest distplot1d(d,:z₁) joinpath(datadir,"distplot1D.png") !istravis
    end
  end

  @testset "DistPlot2D" begin
    if visualtests
      @plottest distplot2d(d,:z₁,:z₂) joinpath(datadir,"distplot2D.png") !istravis
    end
  end

  @testset "CornerPlot" begin
    if visualtests
      @plottest cornerplot(d) joinpath(datadir,"cornerplot.png") !istravis
    end
  end
end
