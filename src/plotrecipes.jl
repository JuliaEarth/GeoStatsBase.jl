# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

# ensembles
include("plotrecipes/ensembles.jl")

# problems
include("plotrecipes/problems/estimation.jl")
include("plotrecipes/problems/simulation.jl")
include("plotrecipes/problems/learning.jl")

# weights
include("plotrecipes/weighting.jl")

# distributions
include("plotrecipes/distplot1D.jl")
include("plotrecipes/distplot2D.jl")
include("plotrecipes/cornerplot.jl")
include("plotrecipes/histograms.jl")

# other plots
include("plotrecipes/hscatter.jl")
