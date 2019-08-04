@testset "Mappers" begin
  data1D = readgeotable(joinpath(datadir,"data1D.tsv"), delim='\t', coordnames=[:x])
  data2D = readgeotable(joinpath(datadir,"data2D.tsv"), delim='\t', coordnames=[:x,:y])

  @testset "NearestMapper" begin
    grid1D = RegularGrid{Float64}(100)
    mappings = map(data1D, grid1D, (:value,), NearestMapper())
    @test mappings[:value] == Dict(100=>11,81=>9,11=>2,21=>3,91=>10,51=>6,61=>7,71=>8,31=>4,41=>5,1=>1)

    grid2D = RegularGrid{Float64}(100,100)
    mappings = map(data2D, grid2D, (:value,), NearestMapper())
    @test mappings[:value] == Dict(5076=>3,2526=>1,7551=>2)

    ps2D = PointSet([25. 50. 75.; 25. 75. 50.])
    mappings = map(data2D, ps2D, (:value,), NearestMapper())
    @test mappings[:value] == Dict(2=>2,3=>3,1=>1)
  end

  @testset "CopyMapper" begin
    d = PointSetData(Dict(:z => rand(10)), rand(2,10))
    g = RegularGrid{Float64}(10,10)

    # copy data to first locations in domain
    mappings = map(d, g, (:z,), CopyMapper())
    @test mappings[:z] == Dict(i=>i for i in 1:10)

    # copy data to last locations in domain
    mappings = map(d, g, (:z,), CopyMapper(91:100))
    @test mappings[:z] == Dict(j=>i for (i,j) in enumerate(91:100))

    # copy first 3 data points to last 3 domain locations
    mappings = map(d, g, (:z,), CopyMapper(1:3, 98:100))
    @test mappings[:z] == Dict(j=>i for (i,j) in enumerate(98:100))
  end
end
