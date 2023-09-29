@testset "Geometric operations" begin
  @testset "describe" begin
    table = (x=rand(10), y=rand(10), z=rand(10))
    sdata = georef(table, rand(2, 10))
    columns = [table.x, table.y, table.z]

    dtable = describe(sdata)
    @test Tables.schema(dtable).names == (:variable, :mean, :minimum, :median, :maximum, :nmissing)
    @test dtable.variable == [:x, :y, :z]
    @test dtable.mean == mean.(columns)
    @test dtable.minimum == minimum.(columns)
    @test dtable.median == median.(columns)
    @test dtable.maximum == maximum.(columns)
    @test dtable.nmissing == count.(ismissing, columns)

    dtable = describe(sdata, funs=[mean, median, std])
    @test Tables.schema(dtable).names == (:variable, :mean, :median, :std)
    @test dtable.variable == [:x, :y, :z]
    @test dtable.mean == mean.(columns)
    @test dtable.median == median.(columns)
    @test dtable.std == std.(columns)

    dtable = describe(sdata, funs=[:mean => x -> sum(x) / length(x), :min => minimum])
    @test Tables.schema(dtable).names == (:variable, :mean, :min)
    @test dtable.variable == [:x, :y, :z]
    @test dtable.mean == sum.(columns) ./ length.(columns)
    @test dtable.min == minimum.(columns)

    dtable = describe(sdata, funs=Dict(:mean => x -> sum(x) / length(x), :max => maximum))
    @test Set(Tables.schema(dtable).names) == Set([:variable, :mean, :max])
    @test dtable.variable == [:x, :y, :z]
    @test dtable.mean == sum.(columns) ./ length.(columns)
    @test dtable.max == maximum.(columns)

    funs = [mean, median, std]
    columns = [table.y, table.z]
    colspecs = [["y", "z"], ("y", "z"), [:y, :z], (:y, :z), [2, 3], (2, 3), r"[yz]"]

    for colspec in colspecs
      dtable = describe(sdata, colspec)
      @test Tables.schema(dtable).names == (:variable, :mean, :minimum, :median, :maximum, :nmissing)
      @test dtable.variable == [:y, :z]
      @test dtable.mean == mean.(columns)
      @test dtable.minimum == minimum.(columns)
      @test dtable.median == median.(columns)
      @test dtable.maximum == maximum.(columns)
      @test dtable.nmissing == count.(ismissing, columns)
    end

    for colspec in colspecs
      dtable = describe(sdata, colspec; funs)
      @test Tables.schema(dtable).names == (:variable, :mean, :median, :std)
      @test dtable.variable == [:y, :z]
      @test dtable.mean == mean.(columns)
      @test dtable.median == median.(columns)
      @test dtable.std == std.(columns)
    end

    # missing values
    a = shuffle([rand(10); fill(missing, 5)])
    b = shuffle([rand(10); fill(missing, 5)])
    table = (; a, b)
    sdata = georef(table, rand(2, 10))
    columns = [a, b]

    dtable = describe(sdata)
    @test Tables.schema(dtable).names == (:variable, :mean, :minimum, :median, :maximum, :nmissing)
    @test dtable.variable == [:a, :b]
    @test dtable.mean == GeoStatsBase._skipmissing(mean).(columns)
    @test dtable.minimum == GeoStatsBase._skipmissing(minimum).(columns)
    @test dtable.median == GeoStatsBase._skipmissing(median).(columns)
    @test dtable.maximum == GeoStatsBase._skipmissing(maximum).(columns)
    @test dtable.nmissing == count.(ismissing, columns)
  end

  @testset "integrate" begin
    grid = CartesianGrid(2, 2)
    mesh = simplexify(grid)
    table = (z=[1, 2, 3, 4, 5, 6, 7, 8, 9], w=[1, 1, 1, 2, 2, 2, 3, 3, 3])
    gdata = GeoTable(grid, vtable=table)
    mdata = GeoTable(mesh, vtable=table)
    ginte = integrate(gdata, :z, :w)
    minte = integrate(mdata, :z, :w)
    @test ginte.z == [3.0, 4.0, 6.0, 7.0]
    @test ginte.w == [1.5, 1.5, 2.5, 2.5]
    @test sum.(Iterators.partition(minte.z, 2)) == ginte.z
    @test sum.(Iterators.partition(minte.w, 2)) == ginte.w
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
    cl = mean(coordinates.(lpts))
    cr = mean(coordinates.(rpts))
    @test cl[1] < cr[1]
    @test cl[2] == cr[2]
    l, r = geosplit(d, 0.5, (0.0, 1.0))
    @test nelements(l) == 50
    @test nelements(r) == 50
    lpts = [centroid(l, i) for i in 1:nelements(l)]
    rpts = [centroid(r, i) for i in 1:nelements(r)]
    cl = mean(coordinates.(lpts))
    cr = mean(coordinates.(rpts))
    @test cl[1] == cr[1]
    @test cl[2] < cr[2]
  end
end
