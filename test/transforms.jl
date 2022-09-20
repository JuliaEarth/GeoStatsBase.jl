@testset "Transforms" begin
  @testset "Builtin" begin
    # transforms that are revertible
    d = georef((z=rand(100), w=rand(100)))
    for p in [Select(:z), Reject(:z), Rename(:z => :a),
              StdNames(), Sort(:z), Sample(10), Filter(x->true),
              DropMissing(), Replace(1.0 => 2.0), Coalesce(0.0),
              Coerce(:z => ST.Continuous), Identity(), Center(),
              Scale(), MinMax(), Interquartile(), ZScore(),
              Quantile(), Functional(sin), EigenAnalysis(:V),
              PCA(), DRS(), SDS(), RowTable(), ColTable()]
      n, c = apply(p, d)
      t = Tables.columns(n)
      r = revert(p, n, c)
      @test n isa Data
      @test r isa Data
    end

    # transforms with categorical variables
    d = georef((c=categorical([1,2,3]),))
    for p in [Levels(:c => [1,2,3]), OneHot(:c)]
      n, c = apply(p, d)
      t = Tables.columns(n)
      r = revert(p, n, c)
      @test n isa Data
      @test r isa Data
    end

    d = georef((z=rand(100), w=rand(100)))
    p = Select(:w)
    n, c = apply(p, d)
    t = Tables.columns(n)
    @test Tables.columnnames(t) == (:w, :geometry)

    d = georef((z=rand(100), w=rand(100)))
    p = Sample(100)
    n, c = apply(p, d)
    r = revert(p, n, c)
    @test r == d
    t = Tables.columns(n)
    @test Tables.columnnames(t) == (:z, :w, :geometry)

    d = georef((a=[1,missing,3], b=[3,2,1]))
    p = DropMissing()
    n, c = apply(p, d)
    @test Tables.columns(values(n)) == (a=[1,3], b=[3,1])
    @test nelements(domain(n)) == 2
    r = revert(p, n, c)
    @test r == d
  end

  @testset "Geospatial" begin
    rng = MersenneTwister(42)

    l = range(-1,stop=1,length=100)
    μ = [x^2 + y^2 for x in l, y in l]
    ϵ = 0.1rand(rng, 100, 100)
    d = georef((z=μ+ϵ, w=rand(100,100)))
    p = Detrend(:z, degree=2)
    n, c = apply(p, d)
    r = revert(p, n, c)
    D = Tables.matrix(values(d))
    R = Tables.matrix(values(r))
    @test isapprox(D, R, atol=1e-6)

    if visualtests
      p₁ = heatmap(asarray(d, :z), title="original")
      p₂ = heatmap(asarray(n, :z), title="detrended")
      plt = plot(p₁, p₂, size=(900,300))
      @test_reference "data/detrend.png" plt
    end
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