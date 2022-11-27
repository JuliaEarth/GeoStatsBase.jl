# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

_exprerror() = throw(ArgumentError("Invalid expression"))

function _split(expr::Expr, rowwise=true)
  if expr.head ≠ :(=)
    _exprerror()
  end

  colname = _colname(expr.args[1])
  colexpr = _colexpr(expr.args[2], rowwise)

  colname, colexpr
end

function _colname(expr::Expr)
  if expr.head == :braces
    :(Symbol($(esc(expr.args[1]))))
  else
    _exprerror()
  end
end

_colname(nm::QuoteNode) = nm
_colname(::Any) = _exprerror()

function _colexpr(expr::Expr, rowwise)
  if expr.head == :braces
    _makeexpr(expr)
  else
    colexpr = copy(expr)
    _preprocess!(colexpr, rowwise)
    colexpr
  end
end

_colexpr(nm::QuoteNode, _) = _makeexpr(nm)
_colexpr(var::Symbol, _) = esc(var)
_colexpr(::Any, _) = _exprerror()

_makeexpr(expr::Expr) = :(getproperty(data, $(esc(expr.args[1]))))
_makeexpr(nm::QuoteNode) = :(getproperty(data, $nm))

function _preprocess!(expr::Expr, rowwise)
  if expr.head ≠ :call
    _exprerror()
  end

  if rowwise
    pushfirst!(expr.args, :broadcast)
  end

  for (i, arg) in enumerate(expr.args)
    if arg isa Symbol
      expr.args[i] = esc(arg)
    end

    if arg isa QuoteNode
      expr.args[i] = _makeexpr(arg)
    end

    if arg isa Expr
      if arg.head == :(.)
        expr.args[i] = esc(arg)
      elseif arg.head == :braces
        expr.args[i] = _makeexpr(arg)
      else
        _preprocess!(arg, rowwise)
      end
    end
  end
end
