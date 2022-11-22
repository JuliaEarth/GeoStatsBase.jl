# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    Variable(name, [type])

A variable with given `name` and machine `type`.
Default machine type is `Float64`.
"""
struct Variable
  name::Symbol
  type::DataType
end

Variable(name) = Variable(name, Float64)

"""
    name(variable)

Return the name of the `variable`.
"""
name(var::Variable) = var.name

"""
    mactype(variable)

Return the machine type of the `variable`.
"""
mactype(var::Variable) = var.type

"""
    variables(data)

Returns the variables stored in `data` as a vector of
[`Variable`](@ref).
"""
function variables(data::Data)
  s = Tables.schema(values(data))
  @. Variable(s.names, nonmissingtype(s.types))
end
