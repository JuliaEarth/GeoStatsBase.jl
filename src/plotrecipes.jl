# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

# domains
include("plotrecipes/domains/point_set.jl")
include("plotrecipes/domains/regular_grid.jl")
include("plotrecipes/domains/structured_grid.jl")
include("plotrecipes/domains/view.jl")

# data
include("plotrecipes/data.jl")

# ensembles
include("plotrecipes/ensembles.jl")

# problems
include("plotrecipes/problems/estimation.jl")
include("plotrecipes/problems/simulation.jl")
include("plotrecipes/problems/learning.jl")

# partitions and weights
include("plotrecipes/partitions.jl")
include("plotrecipes/weighting.jl")

# distribution plots
include("plotrecipes/distplot1D.jl")
include("plotrecipes/distplot2D.jl")
include("plotrecipes/cornerplot.jl")

# other plots
include("plotrecipes/hscatter.jl")
