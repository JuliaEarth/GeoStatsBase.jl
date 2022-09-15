@testset "Transforms" begin
  @testset "Builtin" begin
    d = georef((z=rand(1000), w=rand(1000)))

    n = d |> Quantile()
    t = n |> Tables.columns
    @test n isa GeoData
    @test Tables.columnnames(t) == (:z, :w, :geometry)
  end

  @testset "CoDa" begin
    d = georef((z=rand(1000), w=rand(1000)))

    n = d |> Closure()
    t = Tables.columns(n)
    @test n isa GeoData
    @test Tables.columnnames(t) == (:z, :w, :geometry)

    n = d |> Remainder()
    t = Tables.columns(n)
    @test n isa GeoData
    @test Tables.columnnames(t) == (:z, :w, :remainder, :geometry)

    n = d |> ALR()
    t = Tables.columns(n)
    @test n isa GeoData
    @test Tables.columnnames(t) == (:z, :geometry)

    n = d |> CLR()
    t = Tables.columns(n)
    @test n isa GeoData
    @test Tables.columnnames(t) == (:z, :w, :geometry)

    n = d |> ILR()
    t = Tables.columns(n)
    @test n isa GeoData
    @test Tables.columnnames(t) == (:z, :geometry)
  end
end