# scripts/daisyworld-animate.jl - Анимация модели Daisyworld

using DrWatson
@quickactivate "project"

using Agents
using CairoMakie

include(srcdir("daisyworld.jl"))

# Создаем модель
model = daisyworld()

# Функция для определения цвета маргаритки
daisycolor(a::Daisy) = a.breed == :white ? :white : :black

# Настройки для визуализации
plotkwargs = (
    agent_color = daisycolor,
    agent_size = 20,
    agent_marker = '✩',
    heatarray = :temperature,
    heatkwargs = (colorrange = (-20, 60),)
)

# Создаем анимацию на 60 кадров
println("🎬 Создание анимации...")
abmvideo(
    plotsdir("daisyworld_simulation.mp4"),
    model;
    title = "Daisy World",
    frames = 60,
    plotkwargs...
)

println("✅ Анимация сохранена: ", plotsdir("daisyworld_simulation.mp4"))
