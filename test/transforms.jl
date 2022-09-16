@testset "Transforms" begin
  @testset "Builtin" begin
    # transforms that are revertible
    d = georef((z=rand(100), w=rand(100)))
    for p in [Select(:z), Reject(:z), Rename(:z => :a),
              StdNames(), Replace(1.0 => 2.0), Coalesce(0.0),
              Coerce(:z => Continuous), Identity(), Center(),
              Scale(), MinMax(), Interquartile(), ZScore(),
              Quantile()]
      n, c = apply(p, d)
      t = Tables.columns(n)
      r = revert(p, n, c)
      @test n isa Data
      @test r isa Data
    end

    # transforms with categorical variables
    d = georef((c=categorical([1,2,3]),))
    for p in [Levels(:c => [1,2,3]), OneHot(:c)]
      # n, c = apply(p, d)
      # t = Tables.columns(n)
      # r = revert(p, n, c)
      # @test n isa Data
      # @test r isa Data
    end

    d = georef((z=rand(100), w=rand(100)))
    p = Select(:w)
    n = d |> p
    t = Tables.columns(n)
    @test n isa Data
    @test Tables.columnnames(t) == (:w, :geometry)

    d = georef((z=rand(100), w=rand(100)))
    p = Sample(100)
    n = d |> p
    t = Tables.columns(n)
    @test n isa Data
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