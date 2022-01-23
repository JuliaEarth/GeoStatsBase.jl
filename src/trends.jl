# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    polymat(xs, d)

Return the matrix of monomials for the iterator `xs`, i.e.
for each item `x = (x₁, x₂,…, xₙ)` in `xs`, evaluate
the monomial terms of the expansion `(x₁ + x₂ + ⋯ + xₙ)ᵈ`
for a given degree `d`.

The resulting matrix has a number of rows that is equal
to the number of items in the iterator `xs`. The number
of columns is a function of the degree. For `d=0`, a
single column of ones is returned that corresponds to
the constant term `x₁⁰⋅x₂⁰⋅⋯⋅xₙ⁰` for all items in `xs`.
"""
function polymat(xs, d)
  x  = first(xs)
  n  = length(x)
  es = Iterators.flatten(multiexponents(n, d) for d in 0:d)
  ms = map(es) do e
    map(xs) do x
      prod(x .^ e)
    end
  end
  reduce(hcat, ms)
end

"""
    trend(data, vars; degree=1)

Return the deterministic spatial trend for the variables `vars`
in the spatial `data`. Approximate the trend with a polynomial
of given `degree`.

## References

* Menafoglio, A., Secchi, P. 2013. [A Universal Kriging predictor
  for spatially dependent functional data of a Hilbert Space]
  (https://doi.org/10.1214/13-EJS843)
"""
function trend(data, vars::AbstractVector{Symbol}; degree=1)
  𝒯 = values(data)
  𝒟 = domain(data)

  # build polynomial drift terms
  coords(𝒟, i) = coordinates(centroid(𝒟, i))
  xs = (coords(𝒟, i) for i in 1:nelements(𝒟))
  F  = polymat(xs, degree)

  # eqs 25 and 26 in Menafoglio, A., Secchi, P. 2013.
  ms = map(vars) do var
    z  = Tables.getcolumn(𝒯, var)
    a  = (F'F \ F') * z
    F * a
  end

  ctor  = Tables.materializer(𝒯)
  means = ctor((; zip(vars, ms)...))

  georef(means, 𝒟)
end

trend(data, var::Symbol; kwargs...) = trend(data, [var]; kwargs...)
