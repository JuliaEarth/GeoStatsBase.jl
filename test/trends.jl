@testset "Trends" begin
  Random.seed!(123)

  # constant trend
  d = RegularGridData{Float64}(OrderedDict(:z=>rand(100)))
  z̄ = detrend!(d, :z)[:z]
  @test all(abs.(diff(z̄)) .< 0.01)

  # linear trend
  μ = range(0,stop=1,length=100)
  ϵ = 0.1rand(100)
  d = RegularGridData{Float64}(OrderedDict(:z=>μ + ϵ))
  z̄ = detrend!(d, :z)[:z]
  @test all([abs(z̄[i] - μ[i]) < 0.1 for i in 1:length(z̄)])

  # quadratic trend
  r = range(-1,stop=1,length=100)
  μ = [x^2 + y^2 for x in r, y in r]
  ϵ = 0.1rand(100,100)
  d = RegularGridData{Float64}(OrderedDict(:z=>μ + ϵ))
  z̄ = detrend!(d, :z, degree=2)[:z]
  @test all([abs(z̄[i] - μ[i]) < 0.1 for i in 1:length(z̄)])

  if visualtests
    @plottest begin
      p₁ = heatmap(μ+ϵ, title="z")
      p₂ = heatmap(z̄, title="z trend")
      plot(p₁, p₂, size=(900,300))
    end joinpath(datadir,"trends.png") !istravis
  end
end
