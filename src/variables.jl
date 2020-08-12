# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    Variable(name, type=Float64)

A spatial variable with given `name` and machine `type`.
"""
struct Variable
  name::Symbol
  type::DataType
end

Variable(name) = Variable(name, Float64)

"""
    name(variable)

Return the name of the spatial `variable`.
"""
name(var::Variable) = var.name

"""
    type(variable)

Return the machine type of the spatial `variable`.
"""
type(var::Variable) = var.type

"""
    variables(table)

Return the spatial variables stored in `table`.
"""
function variables(table)
  s = Tables.schema(table)
  ns, ts = s.names, s.types
  @. Variable(ns, nonmissing(ts))
end