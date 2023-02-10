"""
Function that generates CIRCLES datasets. Two methods are provided to generate individual
and multiple concetrical circles.

For single circles:
```
julia>h,w = 6, 4
      R = 2  # radius
      λ = 0  # point noise
      circledata = circle_data_generator(h, w; npoints=10, λ=λ, R=R)
```

For concetrical circles:
```
julia>h,w=(10,10)
      Rs = [1, 3]     # radii
      np = [20, 20]   # npoints
      λ = 0           # point noise
      circledata = circle_data_generator(h, w, np, Rs, λ)
```
"""
function circle_data_generator(height::Int,
                               width::Int;
                               npoints::Int=100,
                               R = min(width, height)/3,
                               center = (width/2.0, height/2.0),
                               λ=1)
    @assert width > 0 && height >0 "Width and height must be > 0."
    @assert R >= 0 "Circle radius must be positive"
    x0, y0 = center
    x = zeros(npoints)
    y = zeros(npoints)
    v = zeros(npoints)  # value vector
    z = λ * rand(npoints,2);
    for (i, θ) in enumerate(range(0, 2pi, npoints))
        x[i] = x0 - R * cos(θ) + z[i,1]
        y[i] = y0 - R * sin(θ) + z[i,2]
        v[i] = 1.0
    end
    x = x .- x0
    y = y .- y0
    return [x y v]
end

function circle_data_generator(height::Int, width::Int, npoints::Vector, Rs::Vector, λ)
    v = zeros(height*width)
    cy = reshape(repeat(1:height,width), height,width)
    cx = reshape(repeat(1:height,width), width, height)' |> Matrix
    reduce(vcat, (circle_data_generator(height,
                                        width;
                                        npoints=npoints[i],
                                        R=Rs[i],
                                        λ=λ) *
                                        [1 0 0; 0 1 0; 0 0 i] # last column i.e. circle label
                                                              # gets multiplied by circle index
                  for i in 1:length(Rs))
           )
end

#= The circle_2_1000.tsv has been generated using the function below with:
```
julia>open("../../data/datasets/circle_2_1000.tsv","w") do fid
          circle_data_generator(fid, 3, 3, [500, 500], [0.3, 1], 0.5)
      end
```
and can be read with:
```
julia>readdlm("../../data/datasets/circle_2_1000.tsv", '\t', header=true)[1]
```
=#
circle_data_generator(io::IO, height::Int, width::Int, npoints::Vector, Rs::Vector, λ; header=true, sep='\t') = begin
    circledata = circle_data_generator(height, width, npoints, Rs, λ)
    header && print(io, "x1 $sep x2 $sep y\n")  # write header
    writedlm(io, circledata)
end
