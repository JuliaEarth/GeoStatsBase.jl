# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

@recipe function f(domain::PointSet{T,N}, data::AbstractVector) where {N,T}
  X = coordinates(domain)

  seriestype --> :scatter

  if N == 1
    X[1,:], data
  elseif N == 2
    aspect_ratio --> :equal
    marker_z --> data
    colorbar --> true
    X[1,:], X[2,:]
  elseif N == 3
    aspect_ratio --> :equal
    marker_z --> data
    colorbar --> true
    X[1,:], X[2,:], X[3,:]
  else
    @error "cannot plot in more than 3 dimensions"
  end
end

@recipe function f(domain::PointSet{T,N}) where {N,T}
  X = coordinates(domain)

  seriestype --> :scatter
  seriescolor --> :black
  legend --> false

  if N == 1
    @series begin
      X[1,:], fill(0, nelms(domain))
    end
  elseif N == 2
    aspect_ratio --> :equal
    @series begin
      X[1,:], X[2,:]
    end
  elseif N == 3
    aspect_ratio --> :equal
    @series begin
      X[1,:], X[2,:], X[3,:]
    end
  else
    @error "cannot plot in more than 3 dimensions"
  end
end
