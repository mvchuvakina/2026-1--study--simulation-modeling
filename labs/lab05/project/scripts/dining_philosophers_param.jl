# # Параметрическое исследование: влияние числа философов
# 
# **Цель:** Исследовать, как количество философов N влияет на
# возникновение deadlock в классической сети.
# 
# ## Параметры исследования
# 
# Исследуем N от 2 до 10.

using DrWatson
@quickactivate

using DataFrames, CSV, Plots
include(srcdir("DiningPhilosophers.jl"))
using .DiningPhilosophers

# Сетка параметров
N_values = 2:10
tmax = 50.0

results = []

println("="^60)
println("ПАРАМЕТРИЧЕСКОЕ ИССЛЕДОВАНИЕ")
println("Влияние количества философов N на deadlock")
println("="^60)

for N in N_values
    println("Исследование N = $N...")
    
    net, u0, _ = build_classical_network(N)
    df = simulate_stochastic(net, u0, tmax)
    dead = detect_deadlock(df, net)
    
    push!(results, (N=N, deadlock=dead))
    println("  Deadlock: $dead")
end

# Сохранение результатов
df_results = DataFrame(results)
CSV.write(datadir("parametric_N_results.csv"), df_results)

# Визуализация
plot(df_results.N, [d ? 1 : 0 for d in df_results.deadlock],
     marker=:circle, linewidth=2,
     xlabel="Количество философов N",
     ylabel="Deadlock (1=да, 0=нет)",
     title="Зависимость deadlock от количества философов")
savefig(plotsdir("parametric_N.png"))

println()
println("Результаты сохранены:")
println("  - data/parametric_N_results.csv")
println("  - plots/parametric_N.png")
