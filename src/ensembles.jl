# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    Ensemble

An ensemble of geospatial realizations.
"""
struct Ensemble{𝒟,ℛ}
  domain::𝒟
  reals::ℛ
  nreals::Int

  function Ensemble{𝒟,ℛ}(domain, reals) where {𝒟,ℛ}
    n = [length(r) for (var, r) in reals]
    @assert length(unique(n)) == 1 "number of realizations must be unique"
    new(domain, reals, n[1])
  end
end

Ensemble(domain::𝒟, reals::ℛ) where {𝒟,ℛ} = Ensemble{𝒟,ℛ}(domain, reals)

# -------------
# VARIABLE API
# -------------

Base.getindex(ensemble::Ensemble, var::Symbol) = ensemble.reals[var]

# -------------
# ITERATOR API
# -------------

Base.iterate(ensemble::Ensemble, state=1) =
  state > ensemble.nreals ? nothing : (ensemble[state], state + 1)
Base.length(ensemble::Ensemble) = ensemble.nreals

# --------------
# INDEXABLE API
# --------------

function Base.getindex(ensemble::Ensemble, ind::Int)
  sdomain = ensemble.domain
  sreals  = ensemble.reals
  idata   = DataFrame([var => reals[ind] for (var, reals) in sreals])
  georef(idata, sdomain)
end
Base.getindex(ensemble::Ensemble, inds::AbstractVector{Int}) =
  [getindex(ensemble, ind) for ind in inds]
Base.firstindex(ensemble::Ensemble) = 1
Base.lastindex(ensemble::Ensemble) = length(ensemble)

# ------------
# IO methods
# ------------
function Base.show(io::IO, ensemble::Ensemble)
  N = embeddim(ensemble.domain)
  print(io, "$(N)D Ensemble")
end

function Base.show(io::IO, ::MIME"text/plain", ensemble::Ensemble)
  println(io, ensemble)
  println(io, "  domain: ", ensemble.domain)
  println(io, "  variables: ", join(keys(ensemble.reals), ", ", " and "))
  print(  io, "  N° reals:  ", ensemble.nreals)
end
