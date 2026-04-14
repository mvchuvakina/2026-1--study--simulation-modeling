using DrWatson
@quickactivate

using DataFrames, CSV, Plots
include(srcdir("DiningPhilosophers.jl"))
using .DiningPhilosophers

N = 5
tmax = 50.0

println("="^60)
println("КЛАССИЧЕСКАЯ СЕТЬ (без арбитра)")
println("="^60)

net_classic, u0_classic, _ = build_classical_network(N)

df_classic = simulate_stochastic(net_classic, u0_classic, tmax)

CSV.write(datadir("dining_classic.csv"), df_classic)

dead = detect_deadlock(df_classic, net_classic)
println("Deadlock обнаружен: $dead")

plot_classic = plot_marking_evolution(df_classic, N)
savefig(plotsdir("classic_simulation.png"))

println()
println("="^60)
println("СЕТЬ С АРБИТРОМ")
println("="^60)

net_arb, u0_arb, _ = build_arbiter_network(N)

df_arb = simulate_stochastic(net_arb, u0_arb, tmax)

CSV.write(datadir("dining_arbiter.csv"), df_arb)

dead_arb = detect_deadlock(df_arb, net_arb)
println("Deadlock обнаружен: $dead_arb")

plot_arb = plot_marking_evolution(df_arb, N)
savefig(plotsdir("arbiter_simulation.png"))

println()
println("="^60)
println("ЭКСПЕРИМЕНТ ЗАВЕРШЁН")
println("="^60)
