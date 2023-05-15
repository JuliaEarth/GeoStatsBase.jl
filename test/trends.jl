@testset "Trends" begin
  rng = MersenneTwister(42)

  # constant trend
  d = georef((z=rand(rng, 100),), CartesianGrid(100))
  z̄ = trend(d, :z).z
  @test all(abs.(diff(z̄)) .< 0.01)

  # linear trend
  μ = range(0, stop=1, length=100)
  ϵ = 0.1rand(rng, 100)
  d = georef((z=μ + ϵ,), CartesianGrid(100))
  z̄ = trend(d, :z).z
  @test all([abs(z̄[i] - μ[i]) < 0.1 for i in 1:length(z̄)])

  # quadratic trend
  r = range(-1, stop=1, length=100)
  μ = [x^2 + y^2 for x in r, y in r]
  ϵ = 0.1rand(rng, 100, 100)
  d = georef((z=μ + ϵ,))
  d̄ = trend(d, :z, degree=2)
  z̄ = reshape(d̄.z, 100, 100)
  @test all([abs(z̄[i] - μ[i]) < 0.1 for i in 1:length(z̄)])

  if visualtests
    p₁ = heatmap(μ + ϵ, title="z")
    p₂ = heatmap(z̄, title="z trend")
    plt = plot(p₁, p₂, size=(900, 300))
    @test_reference "data/trends.png" plt
  end

  d = georef((x=rand(rng, 10), y=rand(rng, 10)), rand(rng, 2, 10))
  𝒯 = d |> trend |> values
  s = Tables.schema(𝒯)
  @test s.names == (:x, :y)
  @test s.types == (Float64, Float64)
end
