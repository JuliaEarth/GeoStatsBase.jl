# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    hscatter(data, var₁, var₂; [options])

H-scatter plot of geospatial `data` for pair of variables
`var₁` and `var₂` with additional `options`.

## Algorithm options:

* `lag`      - lag distance between points (default to `0.0`)
* `tol`      - tolerance for lag distance (default to `1e-1`)
* `distance` - distance from Distances.jl (default to `Euclidean()`)

## Aesthetics options:

* `size`   - size of points in point set
* `color`  - color of geometries or points
* `alpha`  - transparency channel in [0,1]
* `rcolor` - color of regression line
* `icolor` - color of identity line
* `ccolor` - color of center lines

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
