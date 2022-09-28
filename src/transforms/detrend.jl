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
struct Detrend{S<:ColSpec} <: StatelessTableTransform
  colspec::S
  degree::Int
end

Detrend(spec; degree=1) =
  Detrend(colspec(spec), degree)

Detrend(cols::T...; degree=1) where {T<:Col} =
  Detrend(cols; degree=degree)

Detrend(; degree=1) = Detrend(:, degree=degree)

function TableTransforms.preprocess(transform::Detrend, data)
  table  = values(data)
  names  = Tables.schema(table).names
  snames = choose(transform.colspec, names)
  tdata  = trend(data, snames; degree=transform.degree)
  ttable = values(tdata)
  tcols  = Tables.columns(ttable)
  tcols, snames
end

function applyfeat(::Detrend, feat, prep)
  cols  = Tables.columns(feat)
  names = Tables.schema(feat).names

  tcols, snames = prep

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
  newfeat = 𝒯 |> Tables.materializer(feat)

  fcache = prep

  newfeat, fcache
end

function revertfeat(transform::Detrend, newfeat, fcache)
  cols  = Tables.columns(newfeat)
  names = Tables.schema(newfeat).names

  tcols, snames = fcache

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
  𝒯 |> Tables.materializer(newfeat)
end