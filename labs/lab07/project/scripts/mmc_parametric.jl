# Параметрическое исследование M/M/c

using DrWatson
@quickactivate "project"

using ConcurrentSim
using ResumableFunctions
using Distributions
using Random
using Plots
using DataFrames
using Statistics
using JLD2

include(srcdir("mmc.jl"))

println("="^60)
println("ПАРАМЕТРИЧЕСКОЕ ИССЛЕДОВАНИЕ M/M/c")
println("="^60)

script_name = splitext(basename(PROGRAM_FILE))[1]
mkpath(plotsdir(script_name))

# -------------------------------------------------------------------
# 1. ВЛИЯНИЕ КОЛИЧЕСТВА КАНАЛОВ (c)
# -------------------------------------------------------------------
println()
println("1. Влияние количества каналов c")
println("-"^40)

c_vals = 1:5
λ_fixed = 0.9
μ_fixed = 0.5
results_c = []

for c in c_vals
    stats, _ = run_mmc_stats(λ=λ_fixed, μ=μ_fixed, c=c, n_customers=200)
    wait_times = collect(values(stats[:wait_times]))
    push!(results_c, (c=c, Wq=mean(wait_times)))
    println("  c=$c: W_q = $(round(mean(wait_times), digits=4))")
end

p1 = plot([r.c for r in results_c], [r.Wq for r in results_c],
    marker=:circle, linewidth=2,
    xlabel="Количество каналов c", ylabel="Среднее время ожидания W_q",
    title="Влияние числа каналов")
savefig(p1, plotsdir(script_name, "mmc_c.png"))

# -------------------------------------------------------------------
# 2. ВЛИЯНИЕ ЗАГРУЗКИ (ρ)
# -------------------------------------------------------------------
println()
println("2. Влияние загрузки системы ρ")
println("-"^40)

ρ_vals = 0.3:0.1:0.95
c_fixed = 2
μ_fixed = 0.5
results_ρ = []

for ρ in ρ_vals
    λ = ρ * c_fixed * μ_fixed
    stats, _ = run_mmc_stats(λ=λ, μ=μ_fixed, c=c_fixed, n_customers=300)
    wait_times = collect(values(stats[:wait_times]))
    push!(results_ρ, (ρ=ρ, Wq=mean(wait_times)))
    println("  ρ=$(round(ρ, digits=2)): W_q = $(round(mean(wait_times), digits=4))")
end

p2 = plot([r.ρ for r in results_ρ], [r.Wq for r in results_ρ],
    marker=:circle, linewidth=2,
    xlabel="Загрузка системы ρ", ylabel="Среднее время ожидания W_q",
    title="Зависимость времени ожидания от загрузки")
savefig(p2, plotsdir(script_name, "mmc_rho.png"))

# -------------------------------------------------------------------
# 3. ВЛИЯНИЕ ИНТЕНСИВНОСТИ ОБСЛУЖИВАНИЯ (μ)
# -------------------------------------------------------------------
println()
println("3. Влияние интенсивности обслуживания μ")
println("-"^40)

μ_vals = 0.3:0.2:1.2
λ_fixed = 0.9
c_fixed = 2
results_μ = []

for μ in μ_vals
    ρ = λ_fixed / (c_fixed * μ)
    stats, _ = run_mmc_stats(λ=λ_fixed, μ=μ, c=c_fixed, n_customers=200)
    wait_times = collect(values(stats[:wait_times]))
    push!(results_μ, (μ=μ, ρ=ρ, Wq=mean(wait_times)))
    println("  μ=$μ (ρ=$(round(ρ, digits=3))): W_q = $(round(mean(wait_times), digits=4))")
end

p3 = plot([r.μ for r in results_μ], [r.Wq for r in results_μ],
    marker=:circle, linewidth=2,
    xlabel="Интенсивность обслуживания μ", ylabel="Среднее время ожидания W_q",
    title="Влияние быстродействия каналов")
savefig(p3, plotsdir(script_name, "mmc_mu.png"))

# -------------------------------------------------------------------
# 4. СВОДНЫЙ ГРАФИК
# -------------------------------------------------------------------
p_combined = plot(p1, p2, p3, layout=(1,3), size=(1200, 400))
savefig(p_combined, plotsdir(script_name, "mmc_parametric_combined.png"))

# Сохранение результатов
df = DataFrame(results_c)
@save datadir("mmc_results.jld2") df

println()
println("="^60)
println("✅ Параметрическое исследование завершено!")
println("📁 Графики: ", plotsdir(script_name))
println("="^60)
