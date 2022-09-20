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
struct Detrend{S<:TT.ColSpec} <: TT.Stateless
  colspec::S
  degree::Int
end

Detrend(spec; degree=1) =
  Detrend(TT.colspec(spec), degree)

Detrend(cols::T...; degree=1) where {T<:TT.Col} =
  Detrend(cols; degree=degree)

Detrend(; degree=1) = Detrend(:, degree=degree)

function TT.preprocess(transform::Detrend, data)
  table  = values(data)
  names  = Tables.schema(table).names
  snames = TT.choose(transform.colspec, names)
  tdata  = trend(data, snames; degree=transform.degree)
  ttable = values(tdata)
  tcols  = Tables.columns(ttable)
  tcols, snames
end

function TT.applyfeat(::Detrend, feat, prep)
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

function TT.revertfeat(transform::Detrend, newfeat, fcache)
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