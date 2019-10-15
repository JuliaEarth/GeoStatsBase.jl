# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

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
  @param mean = 0.
  @param variogram = GaussianVariogram()
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

  # lines starting with @param refer to variable parameters
  vparams = filter(p -> p.args[1] == Symbol("@param"), content)
  vparams = map(p -> p.args[3], vparams)

  # lines starting with @global refer to global solver parameters
  gparams = filter(p -> p.args[1] == Symbol("@global"), content)
  gparams = map(p -> p.args[3], gparams)

  # add default value of `nothing` if necessary
  gparams = map(p -> p isa Symbol ? :($p = nothing) : p, gparams)

  # replace Expr(:=, a, 2) by Expr(:kw, a, 2) for valid kw args
  gparams = map(p -> Expr(:kw, p.args...), gparams)

  # keyword names
  gkeys = map(p -> p.args[1], gparams)

  # solver parameter type
  solverparam = Symbol(solver,"Param")

  # variables are symbols or tuples of symbols
  varstype = Union{Symbol,NTuple{N,Symbol}} where N

  esc(quote
    $Parameters.@with_kw_noshow struct $solverparam
      __dummy__ = nothing
      $(vparams...)
    end

    @doc (@doc $solverparam) (
    struct $solver <: $solvertype
      params::Dict{$varstype,$solverparam}

      $(gkeys...)

      function $solver(params::Dict{$varstype,$solverparam}, $(gkeys...))
        new(params, $(gkeys...))
      end
    end)

    function $solver(params...; $(gparams...))
      # build dictionary for inner constructor
      dict = Dict{$varstype,$solverparam}()

      # convert named tuples to solver parameters
      for (varname, varparams) in params
        kwargs = [k => v for (k,v) in zip(keys(varparams), varparams)]
        push!(dict, varname => $solverparam(; kwargs...))
      end

      $solver(dict, $(gkeys...))
    end

    # ------------
    # IO methods
    # ------------
    function Base.show(io::IO, solver::$solver)
      print(io, $solver)
    end

    function Base.show(io::IO, ::MIME"text/plain", solver::$solver)
      println(io, solver)
      for (var, varparams) in solver.params
        if var isa Symbol
          println(io, "  └─", var)
        else
          println(io, "  └─", "(", join(var, ", "), ")")
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
