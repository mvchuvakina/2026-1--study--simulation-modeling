using DrWatson
@quickactivate "project"

using Agents
using CairoMakie
using Plots

include(srcdir("daisyworld.jl"))

model = daisyworld()

daisycolor(a::Daisy) = a.breed == :white ? :white : :black

plotkwargs = (
    agent_color = daisycolor,
    agent_size = 20,
    agent_marker = '✩',
    heatarray = :temperature,
    heatkwargs = (colorrange = (-20, 60),)
)

println("Шаг 1: Начальное состояние")
plt1, _ = abmplot(model; plotkwargs...)
save(plotsdir("daisy_step001.png"), plt1)
println("✅ График сохранён: ", plotsdir("daisy_step001.png"))

step!(model, 5)
println("\nШаг 5: После 5 итераций")
plt2, _ = abmplot(model; plotkwargs...)
save(plotsdir("daisy_step005.png"), plt2)
println("✅ График сохранён: ", plotsdir("daisy_step005.png"))

step!(model, 40)
println("\nШаг 45: После 45 итераций")
plt3, _ = abmplot(model; plotkwargs...)
save(plotsdir("daisy_step045.png"), plt3)
println("✅ График сохранён: ", plotsdir("daisy_step045.png"))

println("\n🎉 Базовая визуализация завершена!")
