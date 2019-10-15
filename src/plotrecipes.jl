# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

# domains
include("plotrecipes/domains/curve.jl")
include("plotrecipes/domains/point_set.jl")
include("plotrecipes/domains/regular_grid.jl")
include("plotrecipes/domains/structured_grid.jl")
include("plotrecipes/domains/abstract_domain.jl")

# data
include("plotrecipes/data.jl")

# problems
include("plotrecipes/problems/estimation.jl")
include("plotrecipes/problems/simulation.jl")
include("plotrecipes/problems/learning.jl")

# solutions
include("plotrecipes/solutions/estimation.jl")
include("plotrecipes/solutions/simulation.jl")

# partitions and weights
include("plotrecipes/partitions.jl")
include("plotrecipes/weighting.jl")

# distribution plots
include("plotrecipes/distplot1D.jl")
include("plotrecipes/distplot2D.jl")
include("plotrecipes/cornerplot.jl")
