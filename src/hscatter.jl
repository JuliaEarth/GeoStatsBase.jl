# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    hscatter(data, var₁, var₂; [options])

H-scatter plot of geospatial `data` for pair of variables
`var₁` and `var₂` with additional `options`.

## Algorithm options:

* `lag`      - Lag distance between points in length units (default to `0.0u"m"`)
* `tol`      - Tolerance for lag distance in length units (default to `1e-1u"m"`)
* `distance` - Distance from Distances.jl (default to `Euclidean()`)

## Aesthetics options:

* `size`   - Size of points in point set
* `color`  - Color of geometries or points
* `alpha`  - Transparency channel in [0,1]
* `rcolor` - Color of regression line
* `icolor` - Color of identity line
* `ccolor` - Color of center lines

## Examples

```
# h-scatter of Z vs. Z at lag 1.0
hscatter(data, :Z, :Z, lag=1.0)

# h-scatter of Z vs. W at lag 2.0
hscatter(data, :Z, :W, lag=2.0)
```
"""
function hscatter end
function hscatter! end
