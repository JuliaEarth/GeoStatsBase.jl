# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    SeqSim(var₁=>param₁, var₂=>param₂, ...)

A sequential simulation solver.

## Parameters

* `estimator`    - Estimator used to construct conditional distribution
* `neighborhood` - Neighborhood on which to search neighbors
* `maxneighbors` - Maximum number of neighbors (default to 10)
* `marginal`     - Marginal distribution (default to `Normal()`)
* `path`         - Simulation path (default to `RandomPath`)

For each location in the simulation `path`, a maximum number of
neighbors `maxneighbors` is used to fit a Gaussian distribution.
The neighbors are searched according to a `neighborhood`.
"""
@simsolver SeqSim begin
  @param estimator
  @param neighborhood
  @param minneighbors
  @param maxneighbors
  @param marginal
  @param path
end

function preprocess(problem::SimulationProblem, solver::SeqSim)
  # retrieve problem info
  pdomain = domain(problem)

  # result of preprocessing
  preproc = Dict{Symbol,NamedTuple}()

  for (var, V) in variables(problem)
    # get user parameters
    if var ∈ keys(solver.params)
      varparams = solver.params[var]
    else
      varparams = SeqSimParam()
    end

    # determine maximum number of neighbors
    maxneighbors = varparams.maxneighbors

    # determine neighbor search method
    neigh     = varparams.neighborhood
    searcher  = NeighborhoodSearcher(pdomain, neigh)
    bsearcher = BoundedSearcher(searcher, maxneighbors)

    # save preprocessed input
    preproc[var] = (estimator=varparams.estimator,
                    minneighbors=varparams.minneighbors,
                    maxneighbors=varparams.maxneighbors,
                    marginal=varparams.marginal,
                    path=varparams.path,
                    bsearcher=bsearcher)
  end

  preproc
end

function solve_single(problem::SimulationProblem, var::Symbol,
                      solver::SeqSim, preproc)
  # retrieve problem info
  pdata = data(problem)
  pdomain = domain(problem)

  # unpack preprocessed parameters
  estimator, minneighbors, maxneighbors, marginal, path, bsearcher = preproc[var]

  # determine value type
  V = variables(problem)[var]

  # pre-allocate memory for result
  realization = Vector{V}(undef, npoints(pdomain))

  # pre-allocate memory for coordinates
  xₒ = MVector{ndims(pdomain),coordtype(pdomain)}(undef)

  # pre-allocate memory for neighbors coordinates
  neighbors = Vector{Int}(undef, maxneighbors)
  X = Matrix{coordtype(pdomain)}(undef, ndims(pdomain), maxneighbors)

  # keep track of simulated locations
  simulated = falses(npoints(pdomain))
  for (loc, datloc) in datamap(problem, var)
    realization[loc] = pdata[datloc,var]
    simulated[loc] = true
  end

  # simulation loop
  for location in path
    if !simulated[location]
      # coordinates of neighborhood center
      coordinates!(xₒ, pdomain, location)

      # find neighbors with previously simulated values
      nneigh = search!(neighbors, xₒ, bsearcher, mask=simulated)

      # choose between marginal and conditional distribution
      if nneigh < minneighbors
        # draw from marginal
        realization[location] = rand(marginal)
      else
        # final set of neighbors
        nview = view(neighbors, 1:nneigh)

        # update neighbors coordinates
        coordinates!(X, pdomain, nview)

        Xview = view(X,:,1:nneigh)
        zview = view(realization, nview)

        # fit estimator
        fitted = fit(estimator, Xview, zview)

        if status(fitted)
          # estimate mean and variance
          μ, σ² = predict(fitted, xₒ)

          # draw from conditional
          realization[location] = μ + √σ²*randn(V)
        else
          # draw from marginal
          realization[location] = rand(marginal)
        end
      end

      # mark location as simulated and continue
      simulated[location] = true
    end
  end

  realization
end
