# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

# domains
include("plotrecipes/domains/curve.jl")
include("plotrecipes/domains/point_set.jl")
include("plotrecipes/domains/regular_grid.jl")
include("plotrecipes/domains/structured_grid.jl")
include("plotrecipes/domains/abstract_domain.jl")

# spatial data
include("plotrecipes/spatialdata.jl")

# solutions
include("plotrecipes/solutions/estimation.jl")
include("plotrecipes/solutions/simulation.jl")

# partitions and weights
include("plotrecipes/partitions.jl")
include("plotrecipes/weighting.jl")
