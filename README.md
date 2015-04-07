# Detrended fluctuation analysis (DFA)
=======
## Description
Performs a detrended fluctuation analysis (DFA) and estimates the scaling exponent from the results.
DFA is used to characterize long memory dependence in stochastic fractal time series.

## Usage
`dfa(x, order=1, overlap=0, boxmax=div(length(x), 2), boxmin=2*(order+1), boxratio=2)`

## Arguments
* **x**:  a vector containing a uniformly-sampled real-valued time series.
* **order**:  the order of the polynomial fit. Default: 1.
* **overlap**:  the overlap of blocks in partitioning the time data expressed as a fraction in [
0,1). A positive overlap will slow down the calculations slightly with the (possible)
effect of generating less biased results. Default: 0


