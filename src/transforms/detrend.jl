# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    Detrend(col₁, col₂, ..., colₙ; degree=1)
    Detrend([col₁, col₂, ..., colₙ]; degree=1)
    Detrend((col₁, col₂, ..., colₙ); degree=1)
    
The transform that detrends columns `col₁`, `col₂`, ..., `colₙ`
with a polynomial of given `degree`.

    Detrend(regex; degree=1)

Detrends the columns that match with `regex`.

# Examples

```julia
Detrend(1, 3, 5)
Detrend([:a, :c, :e])
Detrend(("a", "c", "e"))
Detrend(r"[ace]", degree=2)
Detrend(:)
```

See also [`trend`](@ref).
"""
struct Detrend{S<:ColSpec} <: TableTransform
  colspec::S
  degree::Int
end

Detrend(spec; degree=1) = Detrend(colspec(spec), degree)

Detrend(cols::T...; degree=1) where {T<:Col} = Detrend(cols; degree=degree)

Detrend(; degree=1) = Detrend(:, degree=degree)

isrevertible(::Type{<:Detrend}) = true

function apply(transform::Detrend, geotable)
  table = values(geotable)
  cols = Tables.columns(table)
  names = Tables.schema(table).names
  snames = choose(transform.colspec, names)

  tdata = trend(geotable, snames; degree=transform.degree)
  ttable = values(tdata)
  tcols = Tables.columns(ttable)

  ncols = map(names) do n
    x = Tables.getcolumn(cols, n)
    if n ∈ snames
      μ = Tables.getcolumn(tcols, n)
      x .- μ
    else
      x
    end
  end

  𝒯 = (; zip(names, ncols)...)
  newtable = 𝒯 |> Tables.materializer(table)

  newgeotable = georef(newtable, domain(geotable))

  newgeotable, (snames, tcols)
end

function revert(::Detrend, newgeotable, cache)
  newtable = values(newgeotable)
  cols = Tables.columns(newtable)
  names = Tables.schema(newtable).names

  snames, tcols = cache

  ncols = map(names) do n
    x = Tables.getcolumn(cols, n)
    if n ∈ snames
      μ = Tables.getcolumn(tcols, n)
      x .+ μ
    else
      x
    end
  end

  𝒯 = (; zip(names, ncols)...)
  table = 𝒯 |> Tables.materializer(newtable)

  georef(table, domain(newgeotable))
end
