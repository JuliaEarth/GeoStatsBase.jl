# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    hscatter(data, var₁, var₂; [options])

H-scatter plot of geospatial `data` for pair of variables
`var₁` and `var₂`. All available `options` will be documented
below upon loading a Makie.jl backend.

## Examples

```julia
# h-scatter of Z vs. Z at lag 1.0
hscatter(data, :Z, :Z, lag=1.0)

# h-scatter of Z vs. W at lag 2.0
hscatter(data, :Z, :W, lag=2.0)
```

### Notes

This function will only work in the presence of a Makie.jl
backend via package extensions in Julia v1.9 or later
versions of the language.
"""
function hscatter end
function hscatter! end
