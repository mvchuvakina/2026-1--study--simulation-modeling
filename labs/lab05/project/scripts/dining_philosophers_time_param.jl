# # Параметрическое исследование: влияние времени симуляции
# 
# **Цель:** Исследовать, как время симуляции tmax влияет на
# обнаружение deadlock в классической сети.

using DrWatson
@quickactivate

using DataFrames, CSV, Plots
include(srcdir("DiningPhilosophers.jl"))
using .DiningPhilosophers

# Параметры
N = 5
tmax_values = [10.0, 20.0, 30.0, 40.0, 50.0, 60.0, 80.0, 100.0]

results = []

println("="^60)
println("ПАРАМЕТРИЧЕСКОЕ ИССЛЕДОВАНИЕ")
println("Влияние времени симуляции tmax на deadlock")
println("="^60)

for tmax in tmax_values
    println("Исследование tmax = $tmax...")
    
    net, u0, _ = build_classical_network(N)
    df = simulate_stochastic(net, u0, tmax)
    dead = detect_deadlock(df, net)
    
    push!(results, (tmax=tmax, deadlock=dead))
    println("  Deadlock: $dead")
end

df_results = DataFrame(results)
CSV.write(datadir("parametric_tmax_results.csv"), df_results)

plot(df_results.tmax, [d ? 1 : 0 for d in df_results.deadlock],
     marker=:circle, linewidth=2,
     xlabel="Время симуляции tmax",
     ylabel="Deadlock (1=да, 0=нет)",
     title="Зависимость deadlock от времени симуляции")
savefig(plotsdir("parametric_tmax.png"))

println()
println("Результаты сохранены:")
println("  - data/parametric_tmax_results.csv")
println("  - plots/parametric_tmax.png")
