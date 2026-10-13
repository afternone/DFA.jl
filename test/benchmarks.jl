using BenchmarkTools
using CSV
using DataFrames
using DFA

# Define the benchmark function
function benchmark_dfa()
    results = DataFrame(Function=String[], Time=Float64[])
    
    # Benchmark for different input sizes
    for N in [100, 1000, 10000, 100000]
        x = rand(N)
        @btime result = dfa($x)
        time = @belapsed dfa($x)
        
        push!(results, ("dfa($N)", time))
    end
    
    return results
end

# Run the benchmark and save the results
results = benchmark_dfa()
CSV.write("benchmarks.csv", results)