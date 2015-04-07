module DFA

using ArrayViews
export dfa, integrate, polyfit

function integrate{T<:Real}(x::AbstractArray{T})
    N = length(x)
    y = zeros(N)
    sumx = 0.0
    for i=1:N
        sumx += x[i]
        y[i] = sumx
    end
    y
end

function integrate1{T<:Real}(x::AbstractArray{T})
    N = length(x)
    y = zeros(N)
    sumx = 0.0
    meanx = 0.0
    for i=1:N
        sumx += x[i]
        meanx += sumx/i
        y[i] = sumx - meanx
    end
    y
end

function polyfit{S<:Real, T<:Real}(x::AbstractArray{S},
                                   y::AbstractArray{T},
                                   order::Int = 1)
  A = [ float(x[i])^p for i = 1:length(x), p = 0:order ]
  A \ y
end

function dfa{T<:Real}(x::AbstractArray{T},
                      boxsize::Int;
                      order::Int = 1,
                      overlap::Real = 0.0,
                      integrated::Bool = false)
    if boxsize > 1 && order >= 0 && 0.0 <= overlap < 1.0
        if !integrated
            x = integrate(x)
        end
        overlapnum = ifloor(overlap*boxsize)
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
    else
        error("boxsize at least 2, fit order at least 0, overlap must between [0, 1)")
    end
end

function dfa{T<:Real, S<:Real}(x::AbstractArray{T},
                               boxes::AbstractArray{S};
                               order::Int = 1,
                               overlap::Real = 0.0,
                               integrated::Bool = false)
    if !integrated
        x = integrate(x)
        integrated = true
    end
    N = length(boxes)
    fluc = zeros(N)
    for i=1:N
        fluc[i] = dfa(x, boxes[i], order=order, overlap=overlap, integrated=integrated)
    end
    fluc
end

function dfa{T<:Real}(x::AbstractArray{T};
                      order::Int = 1,
                      overlap::Real = 0.0,
                      boxmax::Int = div(length(x), 2),
                      boxmin::Int = 2*(order + 1),
                      boxratio::Real = 2,
                      integrated::Bool = false)
    if boxmax > boxmin
        boxes = unique(int(boxratio.^[log(boxratio, boxmin):log(boxratio, boxmax)]))
        if length(boxes) > 1
            if !integrated
                x = integrate(x)
                integrated = true
            end
            boxes, dfa(x, boxes, order=order, overlap=overlap, integrated=integrated)
        else
            error("box number at least 2")
        end
    else
        error("boxmax must be greater than boxmin, or length(x)/2 must be greater than 2(order+1)")
    end
end

end # module
