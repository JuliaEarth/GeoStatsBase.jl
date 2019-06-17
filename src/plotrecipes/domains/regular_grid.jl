# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

@recipe function f(domain::RegularGrid{T,N}, data::AbstractVector) where {N,T}
  Z = reshape(data, size(domain))

  if N == 1
    seriestype --> :path
    coordinates(domain)[1,:], Z
  elseif N == 2
    seriestype --> :heatmap
    aspect_ratio --> :equal
    seriescolor --> :bluesreds
    colorbar --> true
    reverse(rotr90(Z), dims=2)
  elseif N == 3
    seriestype --> :volume
    aspect_ratio --> :equal
    seriescolor --> :bluesreds
    colorbar --> true
    Z
  else
    @error "cannot plot in more than 3 dimensions"
  end
end

@recipe function f(domain::RegularGrid{T,N}) where {N,T}
  X  = coordinates(domain)
  or = origin(domain)
  sp = spacing(domain)
  sz = size(domain)

  markersize --> 2
  color --> :black
  legend --> false

  if N == 1
    @series begin
      seriestype --> :scatterpath
      X[1,:], fill(zero(T), sz[1])
    end
  elseif N == 2
    aspect_ratio --> :equal
    @series begin
      seriestype --> :scatter
      X[1,:], X[2,:]
    end
    for i in 1:sz[1]
      @series begin
        seriestype --> :path
        [or[1]+(i-1)*sp[1],or[1]+(i-1)*sp[1]], [or[2],or[2]+(sz[2]-1)*sp[2]]
      end
    end
    for j in 1:sz[2]
      @series begin
        seriestype --> :path
        [or[1],or[1]+(sz[1]-1)*sp[1]], [or[2]+(j-1)*sp[2],or[2]+(j-1)*sp[2]]
      end
    end
  elseif N == 3
    aspect_ratio --> :equal
    @series begin
      seriestype --> :scatter
      X[1,:], X[2,:], X[3,:]
    end
    for i in 1:sz[1], j in 1:sz[2]
      @series begin
        seriestype --> :path
        [or[1]+(i-1)*sp[1],or[1]+(i-1)*sp[1]], [or[2]+(j-1)*sp[2],or[2]+(j-1)*sp[2]], [or[3],or[3]+(sz[3]-1)*sp[3]]
      end
    end
    for i in 1:sz[1], k in 1:sz[3]
      @series begin
        seriestype --> :path
        [or[1]+(i-1)*sp[1],or[1]+(i-1)*sp[1]], [or[2],or[2]+(sz[2]-1)*sp[2]], [or[3]+(k-1)*sp[3],or[3]+(k-1)*sp[3]]
      end
    end
    for j in 1:sz[2], k in 1:sz[3]
      @series begin
        seriestype --> :path
        [or[1],or[1]+(sz[1]-1)*sp[1]], [or[2]+(j-1)*sp[2],or[2]+(j-1)*sp[2]], [or[3]+(k-1)*sp[3],or[3]+(k-1)*sp[3]]
      end
    end
  else
    @error "cannot plot in more than 3 dimensions"
  end
end
