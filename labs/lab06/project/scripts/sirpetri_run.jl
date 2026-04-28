# ============================================================================
# Базовый прогон модели SIR на сетях Петри
# ============================================================================

using DrWatson
@quickactivate

using Random
using DataFrames, CSV, Plots

include(srcdir("SIRPetri.jl"))
using .SIRPetri

# Параметры
β = 0.3
γ = 0.1
tmax = 100.0

println("="^60)
println("БАЗОВЫЙ ПРОГОН МОДЕЛИ SIR НА СЕТЯХ ПЕТРИ")
println("="^60)
println("Параметры:")
println("  β = $β (коэффициент заражения)")
println("  γ = $γ (коэффициент выздоровления)")
println("  tmax = $tmax")
println("  Начальные условия: S₀ = 990, I₀ = 10, R₀ = 0")
println()

# Создаём сеть
net, u0, states = build_sir_network(β, γ)

# 1. Детерминированная симуляция
println("1. Детерминированная симуляция (ODE)...")
df_det = simulate_deterministic(net, u0, (0.0, tmax), saveat = 0.5, rates = [β, γ])
CSV.write(datadir("sir_det.csv"), df_det)
println("   Сохранено: data/sir_det.csv")

# 2. Стохастическая симуляция
println("2. Стохастическая симуляция (алгоритм Гиллеспи)...")
Random.seed!(123)
df_stoch = simulate_stochastic(net, u0, (0.0, tmax), rates = [β, γ])
CSV.write(datadir("sir_stoch.csv"), df_stoch)
println("   Сохранено: data/sir_stoch.csv")

# Графики
p_det = plot_sir(df_det)
savefig(plotsdir("sir_det_dynamics.png"))
println("   График (детерм.): plots/sir_det_dynamics.png")

p_stoch = plot_sir(df_stoch)
savefig(plotsdir("sir_stoch_dynamics.png"))
println("   График (стохаст.): plots/sir_stoch_dynamics.png")

println()
println("="^60)
println("БАЗОВЫЙ ПРОГОН ЗАВЕРШЁН")
println("="^60)
