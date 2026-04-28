# ============================================================================
# Анимация детерминированной динамики SIR
# ============================================================================

using DrWatson
@quickactivate

using Plots
using DataFrames

include(srcdir("SIRPetri.jl"))
using .SIRPetri

# Параметры
β = 0.3
γ = 0.1
tmax = 100.0

println("="^60)
println("АНИМАЦИЯ ДИНАМИКИ SIR")
println("="^60)
println("Создание анимации...")

# Создаём сеть и получаем данные
net, u0, states = build_sir_network(β, γ)
df = simulate_deterministic(net, u0, (0.0, tmax), saveat = 0.2, rates = [β, γ])

# Создание анимации
anim = @animate for i in 1:length(df.time)
    bar(
        ["S", "I", "R"],
        [df.S[i], df.I[i], df.R[i]],
        ylims = (0, 1000),
        title = "Время = $(round(df.time[i], digits=1))",
        ylabel = "Численность",
        color = [:blue, :red, :green],
        legend = false,
    )
end

# Сохранение GIF
gif(anim, plotsdir("sir_animation.gif"), fps = 10)
println("Анимация сохранена: plots/sir_animation.gif")

println()
println("="^60)
println("АНИМАЦИЯ ЗАВЕРШЕНА")
println("="^60)
