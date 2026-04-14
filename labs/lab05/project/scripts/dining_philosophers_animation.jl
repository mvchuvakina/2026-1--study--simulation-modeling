using DrWatson
@quickactivate

using Plots, Random
include(srcdir("DiningPhilosophers.jl"))
using .DiningPhilosophers

N = 3
tmax = 30.0

net, u0, names = build_classical_network(N)
Random.seed!(123)
df = simulate_stochastic(net, u0, tmax)

anim = @animate for row in eachrow(df)
    u = [row[col] for col in propertynames(row) if col != :time]
    bar(1:length(u), u,
        legend=false,
        ylims=(0, maximum(u0) + 1),
        xlabel="Позиция",
        ylabel="Фишки",
        title="Время = $(round(row.time, digits=2))")
    xticks!(1:length(u), string.(names), rotation=45)
end

gif(anim, plotsdir("philosophers_simulation.gif"), fps=5)
println("Анимация сохранена: plots/philosophers_simulation.gif")
