"""
Function that generates a XOR dataset of the form:
  1 2 3 4 5 6 
1 x x x o o o
2 x x x o o o
3 x x x o o o
4 o o o x x x
5 o o o x x x        
6 o o o x x x    
                           
 cordinate system: .------>  x/width
                   |  xx oo 
                   |    •-center
                   |  oo xx
                   V  
                   y/height

```
julia> h,w = 6,4
	   xordata = xor_data_generator(h,w,(0,0))
       reshape(xordata[:,3], (h,w))
6×14 Matrix{Float64}:
 1.0  1.0  1.0  1.0  1.0  1.0  1.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0
 1.0  1.0  1.0  1.0  1.0  1.0  1.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0
 1.0  1.0  1.0  1.0  1.0  1.0  1.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0
 0.0  0.0  0.0  0.0  0.0  0.0  0.0  1.0  1.0  1.0  1.0  1.0  1.0  1.0
 0.0  0.0  0.0  0.0  0.0  0.0  0.0  1.0  1.0  1.0  1.0  1.0  1.0  1.0
 0.0  0.0  0.0  0.0  0.0  0.0  0.0  1.0  1.0  1.0  1.0  1.0  1.0  1.0
```
"""
function xor_data_generator(height::Int, width::Int, center=(0,0))
    @assert width > 0 && height >0 "Width and height must be > 0."
    cx, cy = center
    rx = cx-floor(width/2):ceil(width/2)+cx-1
    ry = cy-floor(height/2):ceil(height/2)+cy-1
    rx1 = cx-floor(width/2):cx-1; rx2=cx:ceil(width/2)+cx-1
    ry1 = cy-floor(height/2):cy-1; ry2=cy:ceil(height/2)+cy-1
    v = zeros(height*width)   # value vector
    cx = zeros(height*width)  # x coordinate vector
    cy = zeros(height*width)  # y coordinate vector
    for i in 1:width
        for j in 1:height
            # Fill column by column
            k = (i-1) * height + j
            cx[k] = rx[i]
            cy[k] = ry[j]
            rx[i] in rx1 && ry[j] in ry1 && (v[k] = 1)  # i.e. upper left quadrant, 1
            rx[i] in rx2 && ry[j] in ry2 && (v[k] = 1)  # i.e. lower right quadrant, 1
        end
    end
    return [cx cy v]
end


xor_data_generator(io::IO, height, width, center=(0,0); header=true, sep='\t') = begin
    xordata = xor_data_generator(height, width, center)
    header && print(io, "x1 $sep x2 $sep y\n")  # write header
    writedlm(io, xordata)
end
