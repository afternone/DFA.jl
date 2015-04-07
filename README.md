# DFA.jl: Detrended fluctuation analysis in Julia
=======
## Introduction
The DFA package provides tools to perform a [detrended fluctuation analysis (DFA)](http://en.wikipedia.org/wiki/Detrended_fluctuation_analysis) and estimates the scaling exponent from the results. DFA is used to characterize long memory dependence in stochastic fractal time series.

## Install
To install the package:

`julia> Pkg.clone("git@github.com:afternone/DFA.jl.git")`

## Usage Examples
We'll perform a DFA and estimates the scaling exponent for a random time series.
```
using DFA
using PyPlot

x = rand(10000)
n, Fn = dfa(x)
ployfit(log10(n), log10(Fn))  # the last element is scaling exponent
loglog(n, Fn, "o")
```
You can also specify the following key arguments:

* **order**:  the order of the polynomial fit. Default: `1`.
* **overlap**:  the overlap of blocks in partitioning the time data expressed as a fraction in [
0,1). A positive overlap will slow down the calculations slightly with the (possible)
effect of generating less biased results. Default: `0`.
* **boxmax**: an integer denoting the maximum block size to use in partitioning the data. Default:
`div(length(x), 2)`.
* **boxmin**: an integer denoting the minimum block size to use in partitioning the data. Default: `2*(order+1)`.
* **boxratio**: the ratio of successive boxes. This argument is used as an input to the logScale
function. Default: `2`.

To perform a DFA on x with boxmax=1000, boxmin=4, boxratio=1.2, overlap=0.5:
```
n1, Fn1 = dfa(x, boxmax=1000, boxmin=4, boxratio=1.2, overlap=0.5)
polyfit(log10(n1), log10(Fn1))  # the last element is scaling exponent
loglog(n1, Fn1, "o")
```

## References
* Peng C-K, Buldyrev SV, Havlin S, Simons M, Stanley HE, and Goldberger AL (1994), Mosaic
organization of DNA nucleotides, Physical Review E, 49, 1685–1689.
* Peng C-K, Havlin S, Stanley HE, and Goldberger AL (1995), Quantification of scaling exponents
and crossover phenomena in nonstationary heartbeat time series, Chaos, 5, 82–87.
* Goldberger AL, Amaral LAN, Glass L, Hausdorff JM, Ivanov PCh, Mark RG, Mietus JE, Moody
GB, Peng C-K, Stanley HE (2000, June 13), PhysioBank, PhysioToolkit, and Physionet: Components
of a New Research Resource for Complex Physiologic Signals, Circulation, 101(23), e215-
e220.
