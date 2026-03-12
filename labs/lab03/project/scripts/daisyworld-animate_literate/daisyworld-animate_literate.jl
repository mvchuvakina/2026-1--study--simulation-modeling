using DrWatson
@quickactivate "project"

using Agents
using CairoMakie

include(srcdir("daisyworld.jl"))

model = daisyworld(seed=165)

daisycolor(a::Daisy) = a.breed == :white ? :white : :black

plotkwargs = (
    agent_color = daisycolor,
    agent_size = 20,
    agent_marker = '✩',
    heatarray = :temperature,
    heatkwargs = (colorrange = (-20, 60),)
)

println("="^60)
println("МОДЕЛЬ DAISYWORLD - АНИМАЦИЯ")
println("="^60)
println("\n🎬 Начало создания анимации...")
println("   - Количество кадров: 60")
println("   - Название: 'Daisy World'")
println("   - Формат: MP4")

abmvideo(
    plotsdir("daisyworld_simulation.mp4"),  # путь для сохранения
    model;                                   # модель
    title = "Daisy World",                    # заголовок видео
    frames = 60,                               # количество кадров
    plotkwargs...                              # параметры визуализации
)

println("\n✅ Анимация успешно создана!")
println("   📁 Путь: ", plotsdir("daisyworld_simulation.mp4"))
println("\n📌 Рекомендации по просмотру:")
println("   - Обратите внимание на изменение цвета фона (температуры)")
println("   - Наблюдайте за распространением черных и белых маргариток")
println("   - Видите ли вы, как система приходит к равновесию?")
println("\n" * "="^60)
