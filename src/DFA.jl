module DFA

export dfa, polyfit

function polyfit(x::UnitRange{Int}, y::SubArray{T,1,Array{T,1},Tuple{UnitRange{Int}},true}, order::Int = 1) where T<:Float64
    A = [ float(x[i])^p for i in 1:length(x), p in 0:order ]
    A \ y
end

function polyfit(x::AbstractArray{T,1}, y::AbstractArray{T,1}) where T<:Float64
    A = [ ones(length(x)) x ]
    A \ y
end

function dfa(x::AbstractArray{T},
             boxsize::Int;
             order::Int = 1,
             overlap::Real = 0.0,
             ) where T<:Real
    boxsize < 2 && error("boxsize at least 2")
    0.0 <= overlap < 1.0 || error("overlap must between [0, 1)")
    x = cumsum(x)
    overlapnum = Int(floor(overlap*boxsize)) # Overlap as factor of boxsize
    N = length(x)
    tr = zeros(N)
    i = 0
    fluc = 0.0
    while i*(boxsize-overlapnum)+boxsize <= N
        boxstart = i*(boxsize - overlapnum) + 1
        boxend = i*(boxsize - overlapnum) + boxsize
        p = polyfit(boxstart:boxend, view(x, boxstart:boxend), order)
        for j=boxstart:boxend
            Δ = x[j] - sum([p[k+1]*j^k for k=0:order])
            fluc += Δ*Δ
        end
        i += 1
    end
    sqrt(fluc/i/boxsize)
end

function dfa(x::AbstractArray{T};
             order::Int = 1,
             overlap::Real = 0.0,
             boxmax::Int = div(length(x), 2),
             boxmin::Int = 2*(order + 1),
             boxratio::Real = 2) where T<:Real
    boxmax < boxmin && error("boxmax must be greater than boxmin, or length(x)/2 must be greater than 2(order+1)")
    order < 0 && error("fit order at least 0")
    overlap < 0.0 || overlap >= 1.0 && error("overlap must between [0, 1)")
    boxes = unique(Int.(round.(boxratio.^[log(boxratio, boxmin):log(boxratio, boxmax);], digits=0)))
    length(boxes) < 2 && error("box number at least 2")
    x = x .- (sum(x) / length(x))
    fluc = [ dfa(x, boxes[i], order=order, overlap=overlap) for i=1:length(boxes) ]
    scales = boxes
    return scales, fluc
end

end # module
