# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    KLIEPWeighter(tdata, vars=nothing;
                  bwidth=1.0, nbasis=100)

Kullback-Leibler importance estimation procedure based on empirical
target distribution of variables `vars` in spatial data `tdata`. The
procedure depends on the kernel bandwidth `bwidth` and the number of
basis functions `nbasis`.
"""
struct KLIEPWeighter{DΩ<:AbstractData} <: AbstractWeighter
  tdata::DΩ
  vars::Vector{Symbol}
  bwidth::Float64
  nbasis::Int
end

function KLIEPWeighter(tdata::DΩ, vars=nothing;
                       bwidth=1.0, nbasis=100) where {DΩ<:AbstractData}
  validvars = collect(keys(variables(tdata)))
  wvars = vars ≠ nothing ? vars : validvars
  @assert wvars ⊆ validvars "invalid variables ($wvars) for spatial data"
  @assert nbasis ≤ npoints(tdata) "invalid number of basis functions"
  KLIEPWeighter{DΩ}(tdata, wvars, bwidth, min(nbasis, 100))
end

function weight(sdata::AbstractData, weighter::KLIEPWeighter)
  # retrieve method parameters
  tdata = weighter.tdata
  vars  = weighter.vars
  b     = weighter.nbasis
  σ     = weighter.bwidth

  @assert vars ⊆ keys(variables(sdata)) "invalid variables for spatial data"

  # Gaussian kernel
  kern(x, y) = exp(-norm(x - y)^2 / (2σ^2))

  # number of points in source and target
  nₛ = npoints(sdata)
  nₜ = npoints(tdata)

  # source and target features
  xₛ = i -> sdata[i,vars]
  xₜ = j -> tdata[j,vars]

  # basis for kernel approximation
  basis = sample(1:nₜ, b, replace=false)

  # constants for objective
  Φ = Matrix{Float64}(undef, nₜ, b)
  for l in 1:b
    xₗ = xₜ(basis[l])
    for k in 1:nₜ
      xₖ = xₜ(k)
      Φ[k,l] = kern(xₖ, xₗ)
    end
  end

  # constants for equality constraints
  A = Matrix{Float64}(undef, 1, b)
  for l in 1:b
    xₗ = xₜ(basis[l])
    A[l] = sum(kern(xₛ(k), xₗ) for k in 1:nₛ)
  end
  lc = uc = [nₛ]

  # constants for inequality constraints
  lx = fill(0.0, b)
  ux = fill(Inf, b)

  # objective
  f(α) = -sum(log, Φ*α)
  function ∇f!(g, α)
    p = Φ*α
    for l in 1:b
      g[l] = -sum(Φ[j,l] / p[j] for j in 1:nₛ)
    end
  end
  function ∇²f!(h, α)
    p = Φ*α
    for k in 1:b, l in 1:b
      h[k,l] = sum(view(Φ,:,k) .* view(Φ,:,l) ./ p)
    end
  end

  # equality constraint
  c!(c, α)    = c  .= A*α
  J!(J, α)    = J  .= A
  H!(H, α, λ) = H .+= 0.0

  # initial guess
  αₒ = fill(nₛ/sum(A), b)

  # optimization problem
  objective   = TwiceDifferentiable(f, ∇f!, ∇²f!, αₒ)
  constraints = TwiceDifferentiableConstraints(c!, J!, H!, lx, ux, lc, uc)
  initguess   = αₒ

  # solve problem with interior-point primal-dual Newton
  solution = optimize(objective, constraints, initguess, IPNewton())

  # optimal weights
  α = solution.minimizer
  weights = map(1:nₛ) do i
    sum(α[l] * kern(xₛ(i), xₜ(c)) for (l, c) in enumerate(basis))
  end

  SpatialWeights(domain(sdata), weights)
end
