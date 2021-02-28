# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

# connected component of adjacency matrix containing vertex
function component(adjacency::AbstractMatrix{Int}, vertex::Int)
  frontier = [vertex]
  visited  = Int[]
  # breadth-first search
  while !isempty(frontier)
    u = pop!(frontier)
    push!(visited, u)
    for v in findall(!iszero, adjacency[u,:])
      if v ∉ visited
        push!(frontier, v)
      end
    end
  end
  visited
end

"""
    @metasolver solver solvertype body

A helper macro to create a solver named `solver` of type `solvertype`
with parameters specified in `body`.

## Examples

Create a solver with parameters `mean` and `variogram` for each variable
of the problem, and a global parameter that specifies whether or not
to use the GPU:

```julia
julia> @metasolver MySolver AbstractSimulationSolver begin
  @param mean = 0.0
  @param variogram = GaussianVariogram()
  @jparam rho = 0.7
  @global gpu = false
end
```

### Notes

This macro is not intended to be used directly, see other macros defined
below for estimation and simulation solvers.
"""
macro metasolver(solver, solvertype, body)
  # discard any content that doesn't start with @param or @global
  content = filter(arg -> arg isa Expr, body.args)

  # lines starting with @param refer to single variable parameters
  vparams = filter(p -> p.args[1] == Symbol("@param"), content)
  vparams = map(p -> p.args[3], vparams)

  # lines starting with @jparam refer to joint variable parameters
  jparams = filter(p -> p.args[1] == Symbol("@jparam"), content)
  jparams = map(p -> p.args[3], jparams)

  # lines starting with @global refer to global solver parameters
  gparams = filter(p -> p.args[1] == Symbol("@global"), content)
  gparams = map(p -> p.args[3], gparams)

  # add default value of `nothing` if necessary
  gparams = map(p -> p isa Symbol ? :($p = nothing) : p, gparams)

  # replace Expr(:=, a, 2) by Expr(:kw, a, 2) for valid kw args
  gparams = map(p -> Expr(:kw, p.args...), gparams)

  # keyword names
  gkeys = map(p -> p.args[1], gparams)

  # solver parameter type for single variable
  solvervparam = Symbol(solver,"Param")

  # solver parameter type for joint variables
  solverjparam = Symbol(solver,"JointParam")

  # variables are symbols or tuples of symbols
  vtype = Symbol
  jtype = NTuple{<:Any,Symbol}

  esc(quote
    $Parameters.@with_kw_noshow struct $solvervparam
      __dummy__ = nothing
      $(vparams...)
    end

    $Parameters.@with_kw_noshow struct $solverjparam
      __dummy__ = nothing
      $(jparams...)
    end

    @doc (@doc $solvervparam) (
    struct $solver <: $solvertype
      vparams::Dict{$vtype,$solvervparam}
      jparams::Dict{$jtype,$solverjparam}
      $(gkeys...)

      # auxiliary fields
      varnames::Vector{Symbol}
      adjacency::Matrix{Int}

      function $solver(vparams::Dict{$vtype,$solvervparam},
                       jparams::Dict{$jtype,$solverjparam},
                       $(gkeys...))
        svars = collect(keys(vparams))
        jvars = collect(keys(jparams))
        lens₁ = length.(jvars)
        lens₂ = length.(unique.(jvars))

        @assert all(lens₁ .== lens₂ .> 1) "invalid joint variable specification"

        varnames = svars ∪ Iterators.flatten(jvars)

        adjacency = zeros(Int, length(varnames), length(varnames))
        for (i, u) in enumerate(varnames)
          for vtuple in jvars
            if u ∈ vtuple
              for v in vtuple
                j = indexin([v], varnames)[1]
                i == j || (adjacency[i,j] = 1)
              end
            end
          end
        end

        new(vparams, jparams, $(gkeys...), varnames, adjacency)
      end
    end)

    function $solver(params...; $(gparams...))
      # build dictionaries for inner constructor
      vdict = Dict{$vtype,$solvervparam}()
      jdict = Dict{$jtype,$solverjparam}()

      # convert named tuples to solver parameters
      for (varname, varparams) in params
        kwargs = [k => v for (k,v) in zip(keys(varparams), varparams)]
        if varname isa Symbol
          push!(vdict, varname => $solvervparam(; kwargs...))
        else
          push!(jdict, varname => $solverjparam(; kwargs...))
        end
      end

      $solver(vdict, jdict, $(gkeys...))
    end

    function GeoStatsBase.covariables(var::Symbol, solver::$solver)
      vind = indexin([var], solver.varnames)[1]
      if vind ≠ nothing
        comp = GeoStatsBase.component(solver.adjacency, vind)
        vars = Tuple(solver.varnames[sort(comp)])
        params = []
        for v in vars
          push!(params, (v,) => solver.vparams[v])
        end
        for vtuple in keys(solver.jparams)
          if any(v ∈ vars for v in vtuple)
            push!(params, vtuple => solver.jparams[vtuple])
          end
        end
      else
        # default parameter for single variable
        vars = (var,)
        params = [(var,) => $solvervparam()]
      end

      (names=vars, params=Dict(params))
    end

    Meshes.variables(solver::$solver) = solver.varnames

    # ------------
    # IO methods
    # ------------
    function Base.show(io::IO, solver::$solver)
      print(io, $solver)
    end

    function Base.show(io::IO, ::MIME"text/plain", solver::$solver)
      println(io, solver)
      for (var, varparams) in merge(solver.vparams, solver.jparams)
        if var isa Symbol
          println(io, "  └─", var)
        else
          println(io, "  └─", join(var, "—"))
        end
        pnames = setdiff(fieldnames(typeof(varparams)), [:__dummy__])
        for pname in pnames
          pval = getfield(varparams, pname)
          if pval ≠ nothing
            print(io, "    └─", pname, " ⇨ ")
            show(IOContext(io, :compact => true), pval)
            println(io, "")
          end
        end
      end
    end
  end)
end

"""
    @estimsolver solver body

A helper macro to create a estimation solver named `solver` with parameters
specified in `body`. For examples, please check the documentation for
`@metasolver`.
"""
macro estimsolver(solver, body)
  esc(quote
    GeoStatsBase.@metasolver $solver GeoStatsBase.AbstractEstimationSolver $body
  end)
end

"""
    @estimsolver solver body

A helper macro to create a simulation solver named `solver` with parameters
specified in `body`. For examples, please check the documentation for
`@metasolver`.
"""
macro simsolver(solver, body)
  esc(quote
    GeoStatsBase.@metasolver $solver GeoStatsBase.AbstractSimulationSolver $body
  end)
end
