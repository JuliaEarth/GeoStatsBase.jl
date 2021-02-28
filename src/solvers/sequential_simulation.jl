# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    SeqSim(var₁=>param₁, var₂=>param₂, ...)

A sequential simulation solver.

For each location in the simulation `path`, a maximum number
of neighbors `maxneighbors` is used to fit a distribution.
The neighbors are searched according to a `neighborhood`,
and in case there are none, use a `marginal` distribution.

## Parameters

* `estimator`    - CDF estimator
* `neighborhood` - Spatial neighborhood
* `maxneighbors` - Maximum number of neighbors
* `marginal`     - Marginal distribution
* `path`         - Simulation path
* `mapping`      - Data mapping method
"""
@simsolver SeqSim begin
  @param estimator
  @param neighborhood
  @param minneighbors
  @param maxneighbors
  @param marginal
  @param path
  @param mapping
end

function preprocess(problem::SimulationProblem, solver::SeqSim)
  # retrieve problem info
  pdata = data(problem)
  pdomain = domain(problem)

  # result of preprocessing
  preproc = Dict{Symbol,NamedTuple}()

  for covars in covariables(problem, solver)
    for var in covars.names
      # get user parameters
      varparams = covars.params[(var,)]

      # determine maximum number of neighbors
      maxneighbors = varparams.maxneighbors

      # determine neighbor search method
      neigh     = varparams.neighborhood
      searcher  = NeighborhoodSearch(pdomain, neigh)
      bsearcher = BoundedSearch(searcher, maxneighbors)

      # determine data mappings
      vmappings = if hasdata(problem)
        map(pdata, pdomain, (var,), varparams.mapping)[var]
      else
        Dict()
      end

      # save preprocessed input
      preproc[var] = (estimator=varparams.estimator,
                      minneighbors=varparams.minneighbors,
                      maxneighbors=varparams.maxneighbors,
                      marginal=varparams.marginal,
                      path=varparams.path,
                      bsearcher=bsearcher,
                      mappings=vmappings)
    end
  end

  preproc
end

function solvesingle(problem::SimulationProblem, covars::NamedTuple,
                     solver::SeqSim, preproc)
  # retrieve problem info
  pdata = data(problem)
  pdomain = domain(problem)
  N = embeddim(pdomain)
  T = coordtype(pdomain)

  mactypeof = Dict(name(v) => mactype(v) for v in variables(problem))

  varreals = map(covars.names) do var
    # unpack preprocessed parameters
    estimator, minneighbors, maxneighbors,
    marginal, path, bsearcher, mappings = preproc[var]

    # determine value type
    V = mactypeof[var]

    # pre-allocate memory for result
    realization = Vector{V}(undef, nelements(pdomain))

    # pre-allocate memory for coordinates
    xₒ = MVector{N,T}(undef)

    # pre-allocate memory for neighbors coordinates
    neighbors = Vector{Int}(undef, maxneighbors)
    X = Matrix{T}(undef, N, maxneighbors)

    # keep track of simulated locations
    simulated = falses(nelements(pdomain))
    for (loc, datloc) in mappings
      realization[loc] = pdata[var][datloc]
      simulated[loc] = true
    end

    # simulation loop
    for location in traverse(pdomain, path)
      if !simulated[location]
        # coordinates of neighborhood center
        coordinates!(xₒ, pdomain, location)

        # find neighbors with previously simulated values
        nneigh = search!(neighbors, Point(xₒ), bsearcher, mask=simulated)

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

    var => realization
  end

  Dict(varreals)
end
