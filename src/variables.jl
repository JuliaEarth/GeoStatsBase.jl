# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    Variables(table)

An object that stores variable names and machine types from
the columns of a `table` object.

### Notes

`Variables` behave exactly like `NamedTuple` except that they
iterate over key=>value pairs.
"""
struct Variables{NT}
  nt::NT

  function Variables{NT}(nt) where NT
    new(nt)
  end
end

function Variables(table)
  s = Tables.schema(table)
  ns, ts = s.names, s.types
  nt = NamedTuple{Tuple(ns)}(ts)
  Variables{typeof(nt)}(nt)
end

Base.iterate(vars::Variables) = iterate(pairs(vars.nt))
Base.iterate(vars::Variables, state) = iterate(pairs(vars.nt), state)
Base.eltype(vars::Variables) = eltype(pairs(vars.nt))
Base.length(vars::Variables) = length(vars.nt)
Base.getindex(vars::Variables, ind) = vars.nt[ind]
Base.keys(vars::Variables) = keys(vars.nt)
Base.values(vars::Variables) = values(vars.nt)

# ------------
# IO methods
# ------------
Base.show(io::IO, vars::Variables) = show(io, vars.nt)

function Base.show(io::IO, ::MIME"text/plain", vars::Variables)
  println(io, "variables")
  varlines = ["  └─$var ($V)" for (var,V) in vars]
  print(io, join(sort(varlines), "\n"))
end
