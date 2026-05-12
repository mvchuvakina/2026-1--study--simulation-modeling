# Параметрическое исследование модели Росса

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

include(srcdir("ross.jl"))

println("="^60)
println("ПАРАМЕТРИЧЕСКОЕ ИССЛЕДОВАНИЕ МОДЕЛИ РОССА")
println("="^60)

script_name = splitext(basename(PROGRAM_FILE))[1]
mkpath(plotsdir(script_name))

# -------------------------------------------------------------------
# 1. ВЛИЯНИЕ РАЗМЕРА РЕЗЕРВА (S)
# -------------------------------------------------------------------
println()
println("1. Влияние количества резервных машин S")
println("-"^40)

S_vals = 0:8
results_S = []

for S in S_vals
    t = run_ross_single(N=10, S=S, λ=100.0, μ=1.0)
    push!(results_S, (S=S, time=t))
    println("  S=$S: время до отказа = $(round(t, digits=1)) часов")
end

p1 = plot([r.S for r in results_S], [r.time for r in results_S],
    marker=:circle, linewidth=2,
    xlabel="Количество резервных машин S", ylabel="Время до отказа, часы",
    title="Влияние размера резерва")
savefig(p1, plotsdir(script_name, "ross_S.png"))

# -------------------------------------------------------------------
# 2. ВЛИЯНИЕ КОЛИЧЕСТВА РАБОТАЮЩИХ МАШИН (N)
# -------------------------------------------------------------------
println()
println("2. Влияние количества работающих машин N")
println("-"^40)

N_vals = [5, 10, 15, 20, 25]
S_fixed = 3
results_N = []

for N in N_vals
    t = run_ross_single(N=N, S=S_fixed, λ=100.0, μ=1.0)
    push!(results_N, (N=N, time=t))
    println("  N=$N: время до отказа = $(round(t, digits=1)) часов")
end

p2 = plot([r.N for r in results_N], [r.time for r in results_N],
    marker=:circle, linewidth=2,
    xlabel="Количество работающих машин N", ylabel="Время до отказа, часы",
    title="Влияние числа работающих машин")
savefig(p2, plotsdir(script_name, "ross_N.png"))

# -------------------------------------------------------------------
# 3. ВЛИЯНИЕ КОЛИЧЕСТВА РЕМОНТНИКОВ (R)
# -------------------------------------------------------------------
println()
println("3. Влияние количества ремонтников R")
println("-"^40)

R_vals = 1:5
results_R = []

for R in R_vals
    t = run_ross_multi(N=10, S=3, R=R, λ=100.0, μ=1.0)
    push!(results_R, (R=R, time=t))
    println("  R=$R: время до отказа = $(round(t, digits=1)) часов")
end

p3 = plot([r.R for r in results_R], [r.time for r in results_R],
    marker=:circle, linewidth=2,
    xlabel="Количество ремонтников R", ylabel="Время до отказа, часы",
    title="Влияние числа ремонтников")
savefig(p3, plotsdir(script_name, "ross_R.png"))

# -------------------------------------------------------------------
# 4. ВЛИЯНИЕ ВРЕМЕНИ РЕМОНТА (μ)
# -------------------------------------------------------------------
println()
println("4. Влияние интенсивности ремонта μ")
println("-"^40)

μ_vals = [0.5, 1.0, 2.0, 3.0, 5.0]
results_μ = []

for μ in μ_vals
    t = run_ross_single(N=10, S=3, λ=100.0, μ=μ)
    push!(results_μ, (μ=μ, time=t))
    repair_time = round(1/μ, digits=1)
    println("  μ=$μ (ср. время ремонта = $repair_time): время = $(round(t, digits=1))")
end

p4 = plot([r.μ for r in results_μ], [r.time for r in results_μ],
    marker=:circle, linewidth=2,
    xlabel="Интенсивность ремонта μ", ylabel="Время до отказа, часы",
    title="Влияние скорости ремонта")
savefig(p4, plotsdir(script_name, "ross_mu.png"))

# -------------------------------------------------------------------
# СВОДНЫЙ ГРАФИК
# -------------------------------------------------------------------
p_combined = plot(p1, p2, p3, p4, layout=(2,2), size=(1000, 800))
savefig(p_combined, plotsdir(script_name, "ross_parametric_combined.png"))

# Сохранение результатов
df = DataFrame(results_S)
@save datadir("ross_results.jld2") df

println()
println("="^60)
println("✅ Параметрическое исследование завершено!")
println("📁 Графики: ", plotsdir(script_name))
println("="^60)
