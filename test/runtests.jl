using DFA
using Test
using Random: seed!

import SignalAnalysis: PinkGaussian
import Plots
import HTTP

@testset "DFA" begin
    seed!(137)
    @testset "DFA.simple" begin
        x = randn(1000)
        scales, fluc = dfa(x)
        # x::AbstractArray{T};
        # order::Int = 1,
        # overlap::Real = 0.0,
        # boxmax::Int = div(length(x), 2),
        # boxmin::Int = 2*(order + 1),
        # boxratio::Real = 2) where T<:Real
        @test sum(fluc) ≈ 11.667347467276743 atol=1e-12
        intercept, α = polyfit(log10.(scales), log10.(fluc))
        @test intercept ≈ -0.645847540086 atol=1e-12
        @test α ≈ 0.509373252211 atol=1e-12
        # println("Simple Normal distribution: $intercept, $α")
    end

    # Test wite noise
    @testset "DFA.uniform" begin
        N = 1000
        x = rand(N)
       
        # scales, fluc = dfa(x, order=1, overlap=0.0, boxmax=1000, boxmin=4, boxratio=1.2)
        scales, fluc = dfa(x)
        @test sum(fluc) ≈ 3.689479631618255 atol=1e-12
        intercept, α = polyfit(log10.(scales), log10.(fluc))
        @test intercept ≈ -1.1746914232962604 atol=1e-12
        @test α ≈ 0.5237515930298794 atol=1e-12
        # println("Uniform distribution: $intercept, $α")
    end

    # Test random walk / brownian motion
    @testset "DFA.brownian" begin
        N = 1000
        x = cumsum(randn(N))
        scales, fluc = dfa(x)
        @test sum(fluc) ≈ 351.60733966282874 atol=1e-12
        intercept, α = polyfit(log10.(scales), log10.(fluc))
        @test intercept ≈ -1.4091958750176548 atol=1e-12
        @test α ≈ 1.5477976383996574 atol=1e-12
        # println("Brownian motion: $intercept, $α")
    end

    # Test pink noise
    @testset "DFA.pink" begin
        N = 1000
        x = rand(PinkGaussian(N))
        scales, fluc = dfa(x)
        @test sum(fluc) ≈ 30.27709357289899 atol=1e-12
        intercept, α = polyfit(log10.(scales), log10.(fluc))
        @test intercept ≈ -1.2717558431479488 atol=1e-12
        @test α ≈ 1.0161132560075559 atol=1e-12
        # println("Pink noise: $intercept, $α")
    end

    # Test wite noise
    @testset "DFA.transforms" begin
        @testset "DFA.transforms.scale_translate" begin
            N = 1000
            x = randn(N) .+ 300 .* sin.(2π .* (1:N) ./ 100)
            scales, fluc = dfa(x)
            @test sum(fluc) ≈ 8826.63351956131 atol=1e-1
            intercept, α = polyfit(log10.(scales), log10.(fluc))
            @test intercept ≈ 0.10576185464214086 atol=1e-12
            @test α ≈ 1.5734083037634519 atol=1e-12
            # println("Under scale (300) and translate(sin(2πx/100)): $intercept, $α")
        end

        @testset "DFA.transforms.translate" begin
            N = 1000
            x = randn(N).* 0.01 .+ 300
            scales, fluc = dfa(x)
            @test sum(fluc) ≈ 0.11667347467274337 atol=1e-12
            intercept, α = polyfit(log10.(scales), log10.(fluc))
            @test intercept ≈ -2.6458475400862542 atol=1e-12
            @test α ≈ 0.5093732522114474 atol=1e-12
            # println("Under translate(300): $intercept, $α")
        end
    end

    # Test README
    @testset "DFA.readme" begin
        x = rand(10000)
        scales, fluc = dfa(x, boxmax=1000, boxmin=4, boxratio=1.2, overlap=0.5)
        @test sum(fluc) ≈ 25.03565159644419 atol=1e-12
        intercept, α = polyfit(log10.(scales), log10.(fluc))
        @test intercept ≈ -1.1580257090969381
        @test α ≈ 0.5151987593012474
    end

    # Central limit theorem
    @testset "DFA.stats" begin
        @testset "DFA.stats.pink" begin
            N = 1000
            M = 10000
            alphas = zeros(M)
            for i in 1:M
                x = rand(PinkGaussian(N))
                scales, fluc = dfa(x)
                intercept, α = polyfit(log10.(scales), log10.(fluc))
                alphas[i] = α
            end
            μ_α = sum(alphas) / M
            @test μ_α ≈ 1.0 atol=1e-1
        end
        @testset "DFA.stats.brownian" begin
            N = 1000
            M = 10000
            alphas = zeros(M)
            for i in 1:M
                x = cumsum(randn(N))
                scales, fluc = dfa(x)
                intercept, α = polyfit(log10.(scales), log10.(fluc))
                alphas[i] = α
            end
            μ_α = sum(alphas) / M
            @test μ_α ≈ 1.5 atol=1e-1
        end
        @testset "DFA.stats.uniform" begin
            N = 1000
            M = 10000
            alphas = zeros(M)
            for i in 1:M
                x = rand(N)
                scales, fluc = dfa(x)
                intercept, α = polyfit(log10.(scales), log10.(fluc))
                alphas[i] = α
            end
            μ_α = sum(alphas) / M
            @test μ_α ≈ 0.5 atol=1e-1
        end
    end

    # @testset "DFA.benchmarks" begin
    #     include("benchmarks.jl")
    # end
    
    # @testset "DFA.profile" begin
    #     include("profile.jl")
    # end

    # Test physionet
    @testset "DFA.hrv" begin
        url = "https://physionet.org/files/rr-interval-healthy-subjects/1.0.0/000.txt"
        hrv = parse.(Float64, filter!(e->e!="", split(String(HTTP.get(url).body), r"[^\d.]")))
        x = hrv
    
        scales, fluc = dfa(x)
        log_scales = log10.(scales)
        log_fluc = log10.(fluc)
        intercept, α = polyfit(log_scales, log_fluc)
        @test intercept ≈ 0.6476733308961827
        @test α ≈ 1.0377546755013551 atol=1e-12
        # println("Physionet rr-interval-healthy-subjects/1.0.0/000: $intercept, $α")

        Plots.plot(log_scales, log_fluc, label="DFA", xlabel="Scale Log10", ylabel="Fluctuation Log10", seriestype=:scatter)
        Plots.plot!(log_scales, intercept .+ α .* log_scales, label="DFA Fit")
        Plots.savefig("DFA_A.png")


        scales, fluc = dfa(x, boxmax=div(length(x), 2), boxmin=4, boxratio=2, overlap=0.0)
        log_scales = log10.(scales)
        log_fluc = log10.(fluc)
        intercept, α = polyfit(log_scales, log_fluc)
        @test intercept ≈ 0.6476733308961827 atol=1e-12
        @test α ≈ 1.0377546755013551 atol=1e-12
        Plots.plot(log_scales, log_fluc, label="DFA", xlabel="Scale Log10", ylabel="Fluctuation Log10", seriestype=:scatter)
        Plots.plot!(log_scales, intercept .+ α .* log_scales, label="DFA Fit")
        Plots.savefig("DFA_B.png")

        # HRV α1 and α2: short term (4-16 b/window) and long term (17-64 b/window).
        scales, fluc = dfa(x, boxmax=64, boxmin=4, boxratio=2, overlap=0.0 )
        log_scales = log10.(scales)
        log_fluc = log10.(fluc)
        intercept, α1 = polyfit(log_scales, log_fluc)
        @test intercept ≈ 0.5747573970707875 atol=1e-12
        @test α1 ≈ 1.096221478218021 atol=1e-12
        Plots.plot(log_scales, log_fluc, label="DFA α1", xlabel="Scale Log10", ylabel="Fluctuation Log10", seriestype=:scatter)
        scales, fluc = dfa(x, boxmax=16, boxmin=4, boxratio=2, overlap=0.0 )
        log_scales = log10.(scales)
        log_fluc = log10.(fluc)
        intercept, α2 = polyfit(log_scales, log_fluc)
        @test intercept ≈ 0.5892643049018862 atol=1e-12
        @test α2 ≈ 1.0773259128065056  atol=1e-12
        Plots.plot!(log_scales, log_fluc, label="DFA α2", seriestype=:scatter)
        Plots.plot!(log_scales, intercept .+ α1 .* log_scales, label="DFA Fit α1")
        Plots.plot!(log_scales, intercept .+ α2 .* log_scales, label="DFA Fit α2")
        Plots.savefig("DFA.png")
        # println("Physionet rr-interval-healthy-subjects/1.0.0/000 α1: $α1")
        # println("Physionet rr-interval-healthy-subjects/1.0.0/000 α2: $α2")
        
    end
end
