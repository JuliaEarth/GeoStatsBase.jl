# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    Ensemble

An ensemble of geostatistical realizations from a geostatistical process.
"""
struct Ensemble{𝒟,ℛ}
  domain::𝒟
  reals::ℛ
  nreals::Int

  function Ensemble{𝒟,ℛ}(domain, reals) where {𝒟,ℛ}
    n = [length(r) for r in reals]
    @assert length(unique(n)) == 1 "number of realizations must be unique"
    new(domain, reals, first(n))
  end
end

Ensemble(domain::𝒟, reals::ℛ) where {𝒟,ℛ} = Ensemble{𝒟,ℛ}(domain, reals)

==(e₁::Ensemble, e₂::Ensemble) = e₁.domain == e₂.domain && e₁.reals == e₂.reals

# -------------
# VARIABLE API
# -------------

Base.getindex(e::Ensemble, var::Symbol) = e.reals[var]
Base.getindex(e::Ensemble, var::AbstractString) = getindex(e, Symbol(var))

# -------------
# ITERATOR API
# -------------

Base.iterate(e::Ensemble, state=1) = state > e.nreals ? nothing : (e[state], state + 1)
Base.length(e::Ensemble) = e.nreals

# --------------
# INDEXABLE API
# --------------

function Base.getindex(e::Ensemble, ind::Int)
  sdomain = e.domain
  sreals = pairs(e.reals)
  idata = (; (var => reals[ind] for (var, reals) in sreals)...)
  georef(idata, sdomain)
end
Base.getindex(e::Ensemble, inds::AbstractVector{Int}) = [getindex(e, ind) for ind in inds]
Base.firstindex(e::Ensemble) = 1
Base.lastindex(e::Ensemble) = length(e)

# -----------
# STATISTICS
# -----------

function mean(e::Ensemble)
  mtable = (; (variable => mean(reals) for (variable, reals) in pairs(e.reals))...)
  georef(mtable, e.domain)
end

function var(e::Ensemble)
  vtable = (; (variable => var(reals) for (variable, reals) in pairs(e.reals))...)
  georef(vtable, e.domain)
end

function cdf(e::Ensemble, x::Number)
  cols = []
  for (var, reals) in pairs(e.reals)
    vals = map(1:nelements(e.domain)) do ind
      slice = getindex.(reals, ind)
      _cdf(slice, x)
    end
    push!(cols, var => vals)
  end
  ctable = (; cols...)
  georef(ctable, e.domain)
end

function quantile(e::Ensemble, p::Number)
  cols = []
  for (var, reals) in pairs(e.reals)
    vals = map(1:nelements(e.domain)) do ind
      slice = getindex.(reals, ind)
      quantile(slice, p)
    end
    push!(cols, var => vals)
  end
  qtable = (; cols...)
  georef(qtable, e.domain)
end

quantile(e::Ensemble, ps::AbstractVector) = [quantile(e, p) for p in ps]

# -----------------
# HELPER FUNCTIONS
# -----------------

_cdf(xs, x) = count(≤(x), xs) / length(xs)

# -----------
# IO METHODS
# -----------

function Base.show(io::IO, e::Ensemble)
  N = embeddim(e.domain)
  print(io, "$(N)D Ensemble")
end

function Base.show(io::IO, ::MIME"text/plain", e::Ensemble)
  names = keys(e.reals)
  rvals = values(e.reals)
  types = eltype.(first.(rvals))
  vars = ["$n ($t)" for (n, t) in zip(names, types)]
  println(io, e)
  println(io, "  domain:    ", e.domain)
  println(io, "  variables: ", join(vars, ", ", " and "))
  print(io, "  N° reals:  ", e.nreals)
end
