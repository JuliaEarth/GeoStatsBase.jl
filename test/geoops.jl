@testset "Geometric operations" begin
  @testset "describe" begin
    table = (x=rand(10), y=rand(10), z=rand(10))
    sdata = georef(table, rand(Point, 10))
    columns = [table.x, table.y, table.z]

    dtable = describe(sdata)
    @test Tables.schema(dtable).names == (:variable, :mean, :minimum, :median, :maximum, :nmissing)
    @test dtable.variable == ["x", "y", "z"]
    @test dtable.mean == mean.(columns)
    @test dtable.minimum == minimum.(columns)
    @test dtable.median == median.(columns)
    @test dtable.maximum == maximum.(columns)
    @test dtable.nmissing == count.(ismissing, columns)

    dtable = describe(sdata, mean, median, std)
    @test Tables.schema(dtable).names == (:variable, :mean, :median, :std)
    @test dtable.variable == ["x", "y", "z"]
    @test dtable.mean == mean.(columns)
    @test dtable.median == median.(columns)
    @test isapprox(dtable.std, std.(columns))

    dtable = describe(sdata, :mean => x -> sum(x) / length(x), "min" => minimum, sin ∘ mean)
    @test Tables.schema(dtable).names == (:variable, :mean, :min, Symbol("sin ∘ mean"))
    @test dtable.variable == ["x", "y", "z"]
    @test dtable.mean == sum.(columns) ./ length.(columns)
    @test dtable.min == minimum.(columns)
    @test dtable.var"sin ∘ mean" == (sin ∘ mean).(columns)

    # column selectors
    columns = [table.y, table.z]
    selectors = [["y", "z"], ("y", "z"), [:y, :z], (:y, :z), [2, 3], (2, 3), r"[yz]"]

    for selector in selectors
      dtable = describe(sdata, cols=selector)
      @test Tables.schema(dtable).names == (:variable, :mean, :minimum, :median, :maximum, :nmissing)
      @test dtable.variable == ["y", "z"]
      @test dtable.mean == mean.(columns)
      @test dtable.minimum == minimum.(columns)
      @test dtable.median == median.(columns)
      @test dtable.maximum == maximum.(columns)
      @test dtable.nmissing == count.(ismissing, columns)
    end

    for selector in selectors
      dtable = describe(sdata, mean, median, std, cols=selector)
      @test Tables.schema(dtable).names == (:variable, :mean, :median, :std)
      @test dtable.variable == ["y", "z"]
      @test dtable.mean == mean.(columns)
      @test dtable.median == median.(columns)
      @test isapprox(dtable.std, std.(columns))
    end

    # categorical values
    a = rand(1:9, 10)
    b = rand('a':'z', 10)
    sdata = georef((; a, b), rand(Point, 10))
    columns = [a, b]

    dtable = describe(sdata, mean, last, first)
    @test Tables.schema(dtable).names == (:variable, :mean, :last, :first)
    @test dtable.variable == ["a", "b"]
    @test dtable.mean == [nothing, nothing]
    @test dtable.last == last.(columns)
    @test dtable.first == first.(columns)

    # missing values
    a = shuffle([rand(10); fill(missing, 5)])
    b = shuffle([rand(10); fill(missing, 5)])
    sdata = georef((; a, b), rand(Point, 10))
    columns = [a, b]

    dtable = describe(sdata)
    @test Tables.schema(dtable).names == (:variable, :mean, :minimum, :median, :maximum, :nmissing)
    @test dtable.variable == ["a", "b"]
    @test dtable.mean == GeoStatsBase._skipmissing(mean).(columns)
    @test dtable.minimum == GeoStatsBase._skipmissing(minimum).(columns)
    @test dtable.median == GeoStatsBase._skipmissing(median).(columns)
    @test dtable.maximum == GeoStatsBase._skipmissing(maximum).(columns)
    @test dtable.nmissing == count.(ismissing, columns)

    dtable = describe(sdata, minimum, maximum)
    @test Tables.schema(dtable).names == (:variable, :minimum, :maximum)
    @test dtable.variable == ["a", "b"]
    @test dtable.minimum == GeoStatsBase._skipmissing(minimum).(columns)
    @test dtable.maximum == GeoStatsBase._skipmissing(maximum).(columns)

    dtable = describe(sdata, :nmissing => x -> count(ismissing, x), skipmissing=false)
    @test Tables.schema(dtable).names == (:variable, :nmissing)
    @test dtable.variable == ["a", "b"]
    @test dtable.nmissing == [5, 5]
  end

  @testset "integrate" begin
    grid = CartesianGrid(2, 2)
    mesh = simplexify(grid)
    table = (z=[1, 2, 3, 4, 5, 6, 7, 8, 9], w=[1, 1, 1, 2, 2, 2, 3, 3, 3])
    gdata = GeoTable(grid, vtable=table)
    mdata = GeoTable(mesh, vtable=table)
    ginte = integrate(gdata)
    minte = integrate(mdata)
    @test ginte.z ≈ [3.0, 4.0, 6.0, 7.0]
    @test ginte.w ≈ [1.5, 1.5, 2.5, 2.5]
    @test mean.(Iterators.partition(minte.z, 2)) ≈ ginte.z
    @test mean.(Iterators.partition(minte.w, 2)) ≈ ginte.w
  end

  @testset "geosplit" begin
    d = CartesianGrid(10, 10)
    l, r = geosplit(d, 0.5)
    @test nelements(l) == 50
    @test nelements(r) == 50
    l, r = geosplit(d, 0.5, (1.0, 0.0))
    @test nelements(l) == 50
    @test nelements(r) == 50
    lpts = [centroid(l, i) for i in 1:nelements(l)]
    rpts = [centroid(r, i) for i in 1:nelements(r)]
    cl = mean(to.(lpts))
    cr = mean(to.(rpts))
    @test cl[1] < cr[1]
    @test cl[2] == cr[2]
    l, r = geosplit(d, 0.5, (0.0, 1.0))
    @test nelements(l) == 50
    @test nelements(r) == 50
    lpts = [centroid(l, i) for i in 1:nelements(l)]
    rpts = [centroid(r, i) for i in 1:nelements(r)]
    cl = mean(to.(lpts))
    cr = mean(to.(rpts))
    @test cl[1] == cr[1]
    @test cl[2] < cr[2]
  end
end
