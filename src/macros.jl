# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

# connected component of adjacency matrix containing vertex
function component(adjacency::BitMatrix, vertex::Int)
  frontier = [vertex]
  visited = Int[]
  # breadth-first search
  while !isempty(frontier)
    u = pop!(frontier)
    push!(visited, u)
    for v in findall(adjacency[u, :])
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
julia> @metasolver MySolver SolverType begin
  @param mean = 0.0
  @param variogram = GaussianVariogram()
  @jparam rho = 0.7
  @global gpu = false
end
```

### Notes

This macro is not intended to be used directly, see other macros defined
below for estimation solvers.
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
  solvervparam = Symbol(solver, "Param")

  # solver parameter type for joint variables
  solverjparam = Symbol(solver, "JointParam")

  # variables are symbols or tuples of symbols
  vtype = Set{Symbol}
  jtype = Set{Symbol}

  esc(
    quote
      $Base.@kwdef struct $solvervparam
        __dummy__ = nothing
        $(vparams...)
      end

      $Base.@kwdef struct $solverjparam
        __dummy__ = nothing
        $(jparams...)
      end

      @doc (@doc $solvervparam) (
        struct $solver <: $solvertype
          vparams::Dict{$vtype,$solvervparam}
          jparams::Dict{$jtype,$solverjparam}
          $(gkeys...)

          # common parameters
          progress::Bool

          # auxiliary fields
          varnames::Vector{Symbol}
          adjacency::BitMatrix

          function $solver(
            vparams::Dict{$vtype,$solvervparam},
            jparams::Dict{$jtype,$solverjparam},
            $(gkeys...),
            progress::Bool
          )
            svars = collect(keys(vparams))
            jvars = collect(keys(jparams))

            varnames = Iterators.flatten(svars) ∪ Iterators.flatten(jvars)

            adjacency = falses(length(varnames), length(varnames))
            for (i, u) in enumerate(varnames)
              for vtuple in jvars
                if u ∈ vtuple
                  for v in vtuple
                    j = indexin([v], varnames)[1]
                    i == j || (adjacency[i, j] = true)
                  end
                end
              end
            end

            new(vparams, jparams, $(gkeys...), progress, varnames, adjacency)
          end
        end
      )

      function $solver(params...; $(gparams...), progress=true)
        # build dictionaries for inner constructor
        vdict = Dict{$vtype,$solvervparam}()
        jdict = Dict{$jtype,$solverjparam}()

        # convert named tuples to solver parameters
        for (varname, varparams) in params
          kwargs = [k => v for (k, v) in zip(keys(varparams), varparams)]
          if varname isa Symbol
            push!(vdict, Set([varname]) => $solvervparam(; kwargs...))
          else
            push!(jdict, Set(varname) => $solverjparam(; kwargs...))
          end
        end

        $solver(vdict, jdict, $(gkeys...), progress)
      end

      function GeoStatsBase.covariables(var::Symbol, solver::$solver)
        vind = indexin([var], solver.varnames)[1]
        if !isnothing(vind)
          comp = GeoStatsBase.component(solver.adjacency, vind)
          vars = Set(solver.varnames[sort(comp)])
          params = []
          for v in vars
            key = Set([v])
            push!(params, key => solver.vparams[key])
          end
          for vtuple in keys(solver.jparams)
            if any(v ∈ vars for v in vtuple)
              key = Set(vtuple)
              push!(params, key => solver.jparams[key])
            end
          end
        else
          # default parameter for single variable
          key = Set([var])
          vars = key
          params = [key => $solvervparam()]
        end

        (names=vars, params=Dict(params))
      end

      GeoStatsBase.targets(solver::$solver) = solver.varnames

      # -----------
      # IO METHODS
      # -----------

      function Base.show(io::IO, solver::$solver)
        print(io, $solver)
      end

      function Base.show(io::IO, ::MIME"text/plain", solver::$solver)
        println(io, solver)
        allparams = merge(solver.vparams, solver.jparams)
        for (var, varparams) in allparams
          header = "└─" * join(var, "—")
          pnames = setdiff(fieldnames(typeof(varparams)), [:__dummy__])
          println(io, header)
          for pname in pnames
            pval = getfield(varparams, pname)
            if !isnothing(pval)
              print(io, "  └─", pname, ": ")
              show(IOContext(io, :compact => true), pval)
              println(io, "")
            end
          end
        end
      end
    end
  )
end

"""
    @estimsolver solver body

A helper macro to create a estimation solver named `solver` with parameters
specified in `body`. For examples, please check the documentation for
`@metasolver`.
"""
macro estimsolver(solver, body)
  esc(quote
    GeoStatsBase.@metasolver $solver GeoStatsBase.EstimationSolver $body
  end)
end
