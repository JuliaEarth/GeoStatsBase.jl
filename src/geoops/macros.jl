# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

function _split(expr::Expr, rowwise=true)
  if expr.head ≠ :(=)
    error("Invalid expression")
  end

  colname = expr.args[1]
  colexpr = _colexpr(expr.args[2], rowwise)

  colname, colexpr
end

function _colexpr(arg, rowwise)
  if arg isa Expr
    colexpr = copy(arg)
    _preprocess!(colexpr, rowwise)
  elseif arg isa QuoteNode
    colexpr = _makeexpr(arg)
  elseif arg isa Symbol
    colexpr = esc(arg)
  else
    error("Invalid expression")
  end

  colexpr
end

_makeexpr(nm::QuoteNode) = :($(esc(:getproperty))(data, $nm))

function _preprocess!(expr::Expr, rowwise)
  if expr.head ≠ :call
    error("Invalid expression")
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
      else
        _preprocess!(arg, rowwise)
      end
    end
  end
end
