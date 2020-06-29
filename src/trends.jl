# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
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
  x, _ = iterate(xs)
  n    = length(x)
  exps = Iterators.flatten(multiexponents(n, d) for d in 0:d)
  m = map(exps) do e
    map(xs) do x
      prod(x .^ e)
    end
  end
  reduce(hcat, m)
end

"""
    trend(sdata, vars; degree=1)

Return the deterministic spatial trend for the variables `vars`
in the spatial `sdata`. Approximate the trend with a polynomial
of given `degree`.
"""
function trend(sdata, vars::AbstractVector{Symbol}; degree=1)
  # build LHS of linear system
  xs = eachcol(coordinates(sdata))
  X  = polymat(xs, degree)

  # solve for each variable
  ŷs = map(vars) do var
    y  = sdata[var]
    θ  = X'*X \ X'*y
    ŷ  = X*θ
  end

  data = DataFrame(ŷs, vars)

  georef(data, domain(sdata))
end

trend(sdata, var::Symbol; kwargs...) = trend(sdata, [var]; kwargs...)

"""
    detrend!(sdata, vars; degree=1)

Detrend the variables `vars` in the spatial `sdata` in place,
and return the trends.
"""
function detrend!(sdata, vars::AbstractVector{Symbol}; kwargs...)
  μ = trend(sdata, vars; kwargs...)
  for var in vars
    sdata[var] -= μ[var]
  end
  μ
end

detrend!(sdata, var::Symbol; kwargs...) = detrend!(sdata, [var]; kwargs...)
