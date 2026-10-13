using Profile
using DFA
import SignalAnalysis: PinkGaussian

# Define the profiling function
function profile_dfa()
    x = rand(PinkGaussian(1000))
    @profile dfa(x)
end

println("Profiling DFA.jl...")
profile_dfa()
Profile.print()
println("Done.")