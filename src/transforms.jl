# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

divide(geotable::AbstractGeoTable) = values(geotable), domain(geotable)
attach(table, dom::Domain) = georef(table, dom)

# ----------------
# IMPLEMENTATIONS
# ----------------

include("transforms/utils.jl")
include("transforms/basic.jl")
include("transforms/geometric.jl")
include("transforms/detrend.jl")
include("transforms/potrace.jl")
include("transforms/uniquecoords.jl")
include("transforms/rasterize.jl")
