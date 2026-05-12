# scripts/mmc_run.jl
# Запуск модели M/M/c и построение графиков

using DrWatson
@quickactivate "project"

using Plots
using DataFrames
using Statistics
using LaTeXStrings

include(srcdir("mmc.jl"))

# -------------------------------------------------------------------
# 1. БАЗОВЫЙ ЗАПУСК
# -------------------------------------------------------------------
println("="^60)
println("МОДЕЛЬ M/M/c")
println("="^60)

print("Запуск базовой симуляции... ")
sim_time = run_mmc(λ=0.9, μ=0.5, c=2, n_customers=20)
println("завершено за $sim_time ед. времени")

# -------------------------------------------------------------------
# 2. СБОР СТАТИСТИКИ
# -------------------------------------------------------------------
print("\nСбор статистики... ")
stats, sim_time = run_mmc_stats(λ=0.9, μ=0.5, c=2, n_customers=100)
println("завершено")

wait_times = collect(values(stats[:wait_times]))
service_times = collect(values(stats[:service_times]))

println("\n📊 Статистика:")
println("  Среднее время ожидания в очереди: W_q = ", round(mean(wait_times), digits=4))
println("  Среднее время обслуживания: 1/μ = ", round(mean(service_times), digits=4))
println("  Среднее время в системе: W = ", round(mean(wait_times .+ service_times), digits=4))

# -------------------------------------------------------------------
# 3. ПОСТРОЕНИЕ ГРАФИКОВ
# -------------------------------------------------------------------
script_name = splitext(basename(PROGRAM_FILE))[1]
mkpath(plotsdir(script_name))

# Гистограмма времени ожидания
p1 = histogram(wait_times, 
    bins=20,
    xlabel="Время ожидания в очереди", 
    ylabel="Частота",
    title="Распределение времени ожидания (M/M/2)",
    legend=false,
    color=:blue,
    alpha=0.7
)
savefig(p1, plotsdir(script_name, "mmc_wait_hist.png"))

# Параметрическое исследование: влияние загрузки
loads = 0.3:0.1:0.9
ρ = loads
wait_times_mean = Float64[]

for ρ_val in loads
    λ_val = ρ_val * 2 * 0.5  # λ = ρ * c * μ
    stats, _ = run_mmc_stats(λ=λ_val, μ=0.5, c=2, n_customers=200)
    push!(wait_times_mean, mean(collect(values(stats[:wait_times]))))
end

p2 = plot(loads, wait_times_mean,
    marker=:circle,
    xlabel="Загрузка системы ρ = λ/(c·μ)",
    ylabel="Среднее время ожидания W_q",
    title="Зависимость времени ожидания от загрузки",
    linewidth=2,
    legend=false
)
savefig(p2, plotsdir(script_name, "mmc_load_vs_wait.png"))

println("\n✅ Графики сохранены в: ", plotsdir(script_name))
