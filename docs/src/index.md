```@meta
CurrentModule = DFA
```

<!-- '''@setup
using Random: seed!
seed!(137)
''' -->
# DFA

Documentation for [DFA](https://github.com/abcsds/DFA.jl).

## Introduction

The DFA package provides tools to perform a [detrended fluctuation analysis (DFA)](http://en.wikipedia.org/wiki/Detrended_fluctuation_analysis) and estimates the scaling exponent from the results. DFA is used to characterize long memory dependence in stochastic fractal time series.

## Installation

To install the package, use the following command in the Julia Pkg REPL (press `]` to enter the Pkg REPL):

```julia
pkg> add https://github.com/abcsds/DFA.jl
```

## Usage

### Basic usage

We'll perform a DFA and estimate the scaling exponent for a random time series.

```julia
x = rand(10000)

scales, fluc = dfa(x)
log_scales = log10.(scales)
log_fluc = log10.(fluc)
intercept, α = polyfit(log_scales, log_fluc)
α

# output

0.49706362711274654

```


To estimate the scaling exponent:

```julia
intercept, α = polyfit(log10(scales), log10(fluc))  # α is the scaling exponent
α

# output

0.49706362711274654
```

To plot F(n):

```julia
using Plots

scatter(scales, fluc, label="DFA", xlabel="Scale", ylabel="Fluctuation")
```

To plot F(n) with a fitted line:

```julia
log_scales = log10(scales)
plot(log_scales, log10(fluc), seriestype=:scatter, label="DFA")
plot!(log_scales, α .* log_scales .+ intercept, label="Fit")
```


### Advanced Example

To perform a DFA on heart rate variability data `x`, two different box sizes are commonly used for extracting two coefficients, α1 and α2. The first box size is 4 ≤ n ≤ 16, and the second box size is 16 ≤ n ≤ 64. The scaling exponent α1 is used to quantify the short-term correlation properties of the time series, while α2 is used to quantify the long-term correlation properties of the time series.

```julia
using HTTP

url = "https://physionet.org/files/rr-interval-healthy-subjects/1.0.0/000.txt"
hrv = parse.(Float64, filter!(e->e!="", split(String(HTTP.get(url).body), r"[^\d.]")))
x = hrv

scales, fluc = dfa(x, boxmax=64, boxmin=4, boxratio=2, overlap=0.0 )
log_scales = log10.(scales)
log_fluc = log10.(fluc)
intercept, α1 = polyfit(log_scales, log_fluc)

scales, fluc = dfa(x, boxmax=16, boxmin=4, boxratio=2, overlap=0.0 )
log_scales = log10.(scales)
log_fluc = log10.(fluc)
intercept, α2 = polyfit(log_scales, log_fluc)

println("Physionet rr-interval-healthy-subjects/1.0.0/000 α1: $α1")
println("Physionet rr-interval-healthy-subjects/1.0.0/000 α2: $α2")
(α1, α2)

# output

(1.096221478218021, 1.0773259128065056)
```

## Functions

### `dfa`

```julia
function dfa(x::AbstractArray{T};
             order::Int = 1,
             overlap::Real = 0.0,
             boxmax::Int = div(length(x), 2),
             boxmin::Int = 2*(order + 1),
             boxratio::Real = 2) where T<:Real
```

Performs detrended fluctuation analysis on the input array `x`.

### `polyfit`

```julia
function polyfit(x::AbstractArray{T,1}, y::AbstractArray{T,1}) where T<:Float64
```

Fits a polynomial of the specified order to the data.

## References

- Peng C-K, Buldyrev SV, Havlin S, Simons M, Stanley HE, and Goldberger AL (1994), Mosaic
organization of DNA nucleotides, Physical Review E, 49, 1685–1689.
- Peng C-K, Havlin S, Stanley HE, and Goldberger AL (1995), Quantification of scaling exponents
and crossover phenomena in nonstationary heartbeat time series, Chaos, 5, 82–87.
- Goldberger AL, Amaral LAN, Glass L, Hausdorff JM, Ivanov PCh, Mark RG, Mietus JE, Moody
GB, Peng C-K, Stanley HE (2000, June 13), PhysioBank, PhysioToolkit, and Physionet: Components
of a New Research Resource for Complex Physiologic Signals, Circulation, 101(23), e215-
e220.
- Goldsmith, R. L., Bigger, J. T., Steinman, R. C., & Fleiss, J. L. (1992). Comparison of 24-hour parasympathetic activity in endurance-trained and untrained young men. Journal of the American College of Cardiology, 20(3), 552–558. https://doi.org/10.1016/0735-1097(92)90007-A
- Houda, H. K. N. E. (2023). Multifractal Detrended Fluctuation Analysis of Phonocardiogram signal and classification using Support Vector Machine. Research Square. https://doi.org/10.21203/rs.3.rs-2810058/v1
- Hardstone, R., Poil, S.-S., Schiavone, G., Jansen, R., Nikulin, V. V., Mansvelder, H. D., & Linkenkaer-Hansen, K. (2012). Detrended Fluctuation Analysis: A Scale-Free View on Neuronal Oscillations. Frontiers in Physiology, 3. https://doi.org/10.3389/fphys.2012.00450




```@index
```

```@autodocs
Modules = [DFA]
```