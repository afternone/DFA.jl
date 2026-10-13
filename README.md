# DFA.jl: Detrended fluctuation analysis in Julia

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://abcsds.github.io/DFA.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://abcsds.github.io/DFA.jl/dev/)
[![Build Status](https://github.com/abcsds/DFA.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/abcsds/DFA.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Code Style: Blue](https://img.shields.io/badge/code%20style-blue-4495d1.svg)](https://github.com/invenia/BlueStyle)

## Introduction
The DFA package provides tools to perform a [detrended fluctuation analysis (DFA)](http://en.wikipedia.org/wiki/Detrended_fluctuation_analysis) and estimates the scaling exponent from the results. DFA is used to characterize long memory dependence in stochastic fractal time series.

![DFA](/home/beto/code/DFA.jl/test/DFA_B.png)

## Install
To install the package:

`pkg> add https://github.com/abcsds/DFA.jl`

## Usage Examples
We'll perform a DFA and estimates the scaling exponent for a random time series.
```
using DFA

x = rand(10000)
<!-- n, Fn = dfa(x) -->
Fn = dfa(x)
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
scales, fluc = dfa(x, boxmax=1000, boxmin=4, boxratio=1.2, overlap=0.5)
```
To estimates the scaling exponent:
```
intercept, α = polyfit(log10.(scales), log10.(fluc))  # α is scaling exponent
```
To plot F(n):
```
using plots

scatter(scales, fluc, "o")
```
To plot F(n) with fitted line:
```
log_scales = log10.(scales)
plot(log_scales, log10.(fluc), "o", log_scales, α.*log_scales.+intercept)
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
* Goldsmith, R. L., Bigger, J. T., Steinman, R. C., & Fleiss, J. L. (1992). Comparison of 24-hour parasympathetic activity in endurance-trained and untrained young men. Journal of the American College of Cardiology, 20(3), 552–558. https://doi.org/10.1016/0735-1097(92)90007-A

