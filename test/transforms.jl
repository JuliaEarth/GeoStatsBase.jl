@testset "Transforms" begin
  @testset "Builtin" begin
    # transforms that are revertible
    d = georef((z=rand(100), w=rand(100)))
    for p in [
      Select(:z),
      Reject(:z),
      Rename(:z => :a),
      StdNames(),
      Sort(:z),
      Sample(10),
      Filter(x -> true),
      DropMissing(),
      Replace(1.0 => 2.0),
      Coalesce(value=0.0),
      Coerce(:z => ST.Continuous),
      Identity(),
      Center(),
      Scale(),
      MinMax(),
      Interquartile(),
      ZScore(),
      Quantile(),
      Functional(sin),
      EigenAnalysis(:V),
      PCA(),
      DRS(),
      SDS(),
      RowTable(),
      ColTable()
    ]
      n, c = apply(p, d)
      t = Tables.columns(n)
      r = revert(p, n, c)
      @test n isa Data
      @test r isa Data
    end

    # transforms with categorical variables
    d = georef((c=categorical([1, 2, 3]),))
    for p in [Levels(:c => [1, 2, 3]), OneHot(:c)]
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

    d = georef((a=[1, missing, 3], b=[3, 2, 1]))
    p = DropMissing()
    n, c = apply(p, d)
    @test Tables.columns(values(n)) == (a=[1, 3], b=[3, 1])
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
    xs = first.(coordinates.(cen))
    @test dom isa SimpleMesh
    @test all(x -> -0.5 ≤ x ≤ 0.5, xs)
  end

  @testset "Detrend" begin
    rng = MersenneTwister(42)

    l = range(-1, stop=1, length=100)
    μ = [x^2 + y^2 for x in l, y in l]
    ϵ = 0.1rand(rng, 100, 100)
    d = georef((z=μ + ϵ, w=rand(100, 100)))
    p = Detrend(:z, degree=2)
    n, c = apply(p, d)
    r = revert(p, n, c)
    D = Tables.matrix(values(d))
    R = Tables.matrix(values(r))
    @test isapprox(D, R, atol=1e-6)

    if visualtests
      p₁ = heatmap(asarray(d, :z), title="original")
      p₂ = heatmap(asarray(n, :z), title="detrended")
      plt = plot(p₁, p₂, size=(900, 300))
      @test_reference "data/detrend.png" plt
    end
  end

  @testset "Potrace" begin
    # challenging case with letters
    img = load(joinpath(datadir, "letters.png"))
    dat = georef((color=img,))
    new = dat |> Potrace(1)
    dom = domain(new)
    @test nelements(dom) == 2
    @test eltype(dom) <: Multi
    polys1 = collect(dom[1])
    polys2 = collect(dom[2])
    @test length(polys1) == 4
    @test length(polys2) == 2

    # concentric circles
    ball1 = Ball((0, 0), 1)
    ball2 = Ball((0, 0), 2)
    ball3 = Ball((0, 0), 3)
    grid = CartesianGrid((-5, -5), (5, 5), dims=(100, 100))
    inds1 = centroid.(grid) .∈ Ref(ball1)
    inds2 = centroid.(grid) .∈ Ref(ball2)
    inds3 = centroid.(grid) .∈ Ref(ball3)
    mask = zeros(100, 100)
    mask[inds3] .= 1
    mask[inds2] .= 0
    mask[inds1] .= 1
    dat = georef((mask=mask,))
    new = dat |> Potrace(1)
    dom = domain(new)
    @test nelements(dom) == 2
    @test eltype(dom) <: Multi
    polys1 = collect(dom[1])
    polys2 = collect(dom[2])
    @test length(polys1) == 2
    @test length(polys2) == 2
    new1 = dat |> Potrace(1, ϵ=0.1)
    new2 = dat |> Potrace(1, ϵ=0.5)
    dom1 = domain(new1)
    dom2 = domain(new2)
    for (g1, g2) in zip(dom1, dom2)
      @test nvertices(g1) > nvertices(g2)
    end

    # make sure that aggregation works
    Z = [sin(i / 10) + sin(j / 10) for i in 1:100, j in 1:100]
    M = Z .> 0
    Ω = georef((Z=Z, M=M))
    𝒯 = Ω |> Potrace(:M)
    @test nelements(domain(𝒯)) == 2
    @test Set(𝒯.M) == Set([true, false])
    @test all(z -> -1 ≤ z ≤ 1, 𝒯.Z)
  end

  @testset "UniqueCoords" begin
    @test isrevertible(UniqueCoords()) == false

    X = [i * j for i in 1:2, j in 1:1_000_000]
    z = rand(1_000_000)
    d = georef((z=[z; z],), [X X])
    u = d |> UniqueCoords()
    du = domain(u)
    p = [centroid(du, i) for i in 1:nelements(du)]
    U = reduce(hcat, coordinates.(p))
    @test nelements(du) == 1_000_000
    @test Set(eachcol(U)) == Set(eachcol(X))

    X = rand(3, 100)
    z = rand(100)
    n = [string(i) for i in 1:100]
    Xd = hcat(X, X[:, 1:10])
    zd = vcat(z, z[1:10])
    nd = vcat(n, n[1:10])
    sdata = georef((z=zd, n=nd), PointSet(Xd))
    ndata = sdata |> UniqueCoords()
    @test nitems(ndata) == 100

    # domain with repeated points
    x = rand(100)
    y = rand(1:10, 100)
    table = (; x, y)
    points = Point.(1:10, 10:-1:1)

    pset = PointSet(rand(points, 100))
    sdata = georef(table, pset)
    ndata = sdata |> UniqueCoords()
    @test nitems(ndata) == 10

    # aggregators
    pset = PointSet(repeat(points, inner=10))
    sdata = georef(table, pset)

    # default aggregators
    ndata = sdata |> UniqueCoords()
    @test nitems(ndata) == 10

    for i in 1:10
      j = i * 10
      @test ndata.x[i] == mean(sdata.x[(j - 9):j])
    end

    for i in 1:10
      j = i * 10
      @test ndata.y[i] == first(sdata.y[(j - 9):j])
    end

    # custom aggregators
    # colspec: index
    ndata = sdata |> UniqueCoords(1 => std, 2 => median)
    @test nitems(ndata) == 10

    for i in 1:10
      j = i * 10
      @test ndata.x[i] == std(sdata.x[(j - 9):j])
    end

    for i in 1:10
      j = i * 10
      @test ndata.y[i] == median(sdata.y[(j - 9):j])
    end

    # colspec: symbols
    ndata = sdata |> UniqueCoords(:x => last, :y => first)
    @test nitems(ndata) == 10

    for i in 1:10
      j = i * 10
      @test ndata.x[i] == last(sdata.x[(j - 9):j])
    end

    for i in 1:10
      j = i * 10
      @test ndata.y[i] == first(sdata.y[(j - 9):j])
    end

    # colspec: strings
    ndata = sdata |> UniqueCoords("x" => maximum, "y" => minimum)
    @test nitems(ndata) == 10

    for i in 1:10
      j = i * 10
      @test ndata.x[i] == maximum(sdata.x[(j - 9):j])
    end

    for i in 1:10
      j = i * 10
      @test ndata.y[i] == minimum(sdata.y[(j - 9):j])
    end
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
    p = Quantile() → StdCoords()
    n, c = apply(p, d)
    r = revert(p, n, c)
    Xr = Tables.matrix(values(r))
    Xd = Tables.matrix(values(d))
    @test isapprox(Xr, Xd, atol=0.1)
  end
end
