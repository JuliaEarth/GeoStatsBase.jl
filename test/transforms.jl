@testset "Transforms" begin
  @testset "Builtin" begin
    # transforms that are revertible
    d = georef((z=rand(100), w=rand(100)))
    for p in [Select(:z), Reject(:z), Rename(:z => :a),
              StdNames(), Sort(:z), Sample(10), Filter(x->true),
              DropMissing(), Replace(1.0 => 2.0), Coalesce(value=0.0),
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

  @testset "Geometric" begin
    d = georef((z=rand(100), w=rand(100)))
    p = StdCoords()
    n, c = apply(p, d)
    dom = domain(n)
    cen = centroid.(dom)
    xs  = first.(coordinates.(cen))
    @test dom isa SimpleMesh
    @test all(x -> -0.5 ≤ x ≤ 0.5, xs)
  end

  @testset "Detrend" begin
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

  @testset "Potrace" begin
    img = load(joinpath(datadir,"letters.png"))
    dat = georef((color=img,))
    new = dat |> Potrace(:color)
    dom = domain(new)
    @test nelements(dom) == 2
    @test eltype(dom) <: Multi
    multi1 = dom[1]
    multi2 = dom[2]
    polys1 = collect(multi1)
    polys2 = collect(multi2)
    @test length(polys1) == 1
    @test length(polys2) == 2

    ball1 = Ball((0,0), 1)
    ball2 = Ball((0,0), 2)
    ball3 = Ball((0,0), 3)
    grid  = CartesianGrid((-5,-5), (5,5), dims=(100,100))
    inds1 = centroid.(grid) .∈ Ref(ball1)
    inds2 = centroid.(grid) .∈ Ref(ball2)
    inds3 = centroid.(grid) .∈ Ref(ball3)
    vals  = zeros(100, 100)
    vals[inds3] .= 1
    vals[inds2] .= 0
    vals[inds1] .= 1
    dat = georef((color=vals,))
    new = dat |> Potrace(1)
  end

  @testset "CoDa" begin
    d = georef((z=rand(1000), w=rand(1000)))

    n = d |> Closure()
    t = Tables.columns(n)
    @test n isa Data
    @test Tables.columnnames(t) == (:z, :w, :geometry)

    n = d |> Remainder()
    t = Tables.columns(n)
    @test n isa Data
    @test Tables.columnnames(t) == (:z, :w, :remainder, :geometry)

    n = d |> ALR()
    t = Tables.columns(n)
    @test n isa Data
    @test Tables.columnnames(t) == (:z, :geometry)

    n = d |> CLR()
    t = Tables.columns(n)
    @test n isa Data
    @test Tables.columnnames(t) == (:z, :w, :geometry)

    n = d |> ILR()
    t = Tables.columns(n)
    @test n isa Data
    @test Tables.columnnames(t) == (:z, :geometry)
  end

  @testset "Mixed" begin
    d = georef((z=rand(1000), w=rand(1000)))
    p = Closure() → Quantile() → StdCoords()
    n, c = apply(p, d)
    r = revert(p, n, c)
    Xr = Tables.matrix(values(r))
    Xd = Tables.matrix(values(d))
    @test isapprox(Xr, Xd, atol=0.1)
  end
end